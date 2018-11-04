require "trailblazer/v2_1/context"

class Trailblazer::V2_1::Activity < Module
  module TaskWrap
    # Creates taskWrap steps to map variables before and after the actual step.
    # We hook into the Normalizer, process `:input` and `:output` directives and
    # translate them into a {DSL::Extension}.
    #
    # Note that the two options are not the only way to create filters, you can use the
    # more low-level {Scoped()} etc., too, and write your own filter logic.
    module VariableMapping
      # DSL step for Magnetic::Normalizer.
      # Translates `:input` and `:output` into VariableMapping taskWrap extensions.
      def self.normalizer_step_for_input_output(ctx, *)
        options, io_config = Magnetic::Options.normalize( ctx[:options], [:input, :output] )

        return if io_config.empty?

        ctx[:options] = options # without :input and :output
        ctx[:options] = options.merge(Trailblazer::V2_1::Activity::TaskWrap::VariableMapping(io_config) => true)
      end

      # The taskWrap extension that's included into the static taskWrap for a task.
      def self.extension_for(input, output)
        Trailblazer::V2_1::Activity::DSL::Extension.new(
          Merge.new(
            Module.new do
              extend Path::Plan()

              task input,  id: "task_wrap.input", before: "task_wrap.call_task"
              task output, id: "task_wrap.output", before: "End.success", group: :end
            end
          )
        )
      end
    end

    # @private
    def self.filter_for(filter)
      if filter.is_a?(::Array) || filter.is_a?(::Hash)
        TaskWrap::DSL.filter_from_dsl(filter)
      else
        filter
      end
    end


    # Returns an Extension instance to be thrown into the `step` DSL arguments.
    def self.VariableMapping(input:, output:)
      input  = Input.new(
                Input::Scoped.new(
                  Trailblazer::V2_1::Option::KW( filter_for(input) ) ) )

      output = Output.new(
                Output::Unscoped.new(
                  Trailblazer::V2_1::Option::KW( filter_for(output) ) ) )

      VariableMapping.extension_for(input, output)
    end

    # TaskWrap step to compute the incoming {Context} for the wrapped task.
    # This allows renaming, filtering, hiding, of the options passed into the wrapped task.
    #
    # Both Input and Output are typically to be added before and after task_wrap.call_task.
    #
    # @note Assumption: we always have :input _and_ :output, where :input produces a Context and :output decomposes it.

    # Calls your {@filter} and replaces the original ctx with your returned one.
    class Input
      def initialize(filter)
        @filter = filter
      end

      # `original_args` are the actual args passed to the wrapped task: [ [options, ..], circuit_options ]
      #
      def call( (wrap_ctx, original_args), circuit_options )
        # let user compute new ctx for the wrapped task.
        input_ctx = apply_filter(*original_args)

        wrap_ctx = wrap_ctx.merge( vm_original_ctx: original_args[0][0] ) # remember the original ctx

        # decompose the original_args since we want to modify them.
        (original_ctx, original_flow_options), original_circuit_options = original_args

        # instead of the original Context, pass on the filtered `input_ctx` in the wrap.
        return Trailblazer::V2_1::Activity::Right, [ wrap_ctx, [[input_ctx, original_flow_options], original_circuit_options] ]
      end

      private

      def apply_filter((ctx, original_flow_options), original_circuit_options)
        @filter.( ctx, original_circuit_options ) # returns {new_ctx}.
      end

      class Scoped
        def initialize(filter)
          @filter = filter
        end

        def call(original_ctx, circuit_options)
          Trailblazer::V2_1::Context( # TODO: make this interchangeable so we can work on faster contexts?
            @filter.(original_ctx, **circuit_options)
          )
        end
      end
    end

    module DSL
      # The returned filter compiles a new hash for Scoped/Unscoped that only contains
      # the desired i/o variables.
      def self.filter_from_dsl(map)
        hsh = DSL.hash_for(map)

        ->(incoming_ctx, kwargs) { Hash[hsh.collect { |from_name, to_name| [to_name, incoming_ctx[from_name]] }] }
      end

      def self.hash_for(ary)
        return ary if ary.instance_of?(::Hash)
        Hash[ary.collect { |name| [name, name] }]
      end
    end

    # TaskWrap step to compute the outgoing {Context} from the wrapped task.
    # This allows renaming, filtering, hiding, of the options returned from the wrapped task.
    class Output
      def initialize(filter)
        @filter = filter
      end

      # Runs your filter and replaces the ctx in `wrap_ctx[:return_args]` with the filtered one.
      def call( (wrap_ctx, original_args), **circuit_options )
        (original_ctx, original_flow_options), original_circuit_options = original_args

        returned_ctx, _ = wrap_ctx[:return_args] # this is the Context returned from `call`ing the task.
        original_ctx    = wrap_ctx[:vm_original_ctx]
        # let user compute the output.
        output_ctx = @filter.(original_ctx, returned_ctx, **original_circuit_options)

        wrap_ctx = wrap_ctx.merge( return_args: [output_ctx, original_flow_options] )

        # and then pass on the "new" context.
        return Trailblazer::V2_1::Activity::Right, [ wrap_ctx, original_args ]
      end

      private

      # Merge the resulting {@filter.()} hash back into the original ctx.
      # DISCUSS: do we need the original_ctx as a filter argument?
      class Unscoped
        def initialize(filter)
          @filter = filter
        end

        def call(original_ctx, new_ctx, **circuit_options)
          original_ctx.merge(
            @filter.(new_ctx, **circuit_options)
          )
        end
      end
    end
  end # Wrap
end
