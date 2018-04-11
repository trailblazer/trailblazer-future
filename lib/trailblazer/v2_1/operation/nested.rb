# per default, everything we pass into a circuit is immutable. it's the ops/act's job to allow writing (via a Context)
module Trailblazer::V2_1
  class Operation
    # {Nested} macro.
    def self.Nested(callable, input:nil, output:nil, id: "Nested(#{callable})")
      task_wrap_extensions        = Module.new do
        extend Activity::Path::Plan()
      end

      task, operation, is_dynamic = Nested.build(callable)

      # TODO: move this to the generic step DSL
      if input || output
        task_wrap_extensions = InputOutput.plan( input, output )
      end

      if is_dynamic
        task_wrap_extensions.task task.method(:compute_nested_activity), id: ".compute_nested_activity",  after: "Start.default", group: :start
        task_wrap_extensions.task task.method(:compute_return_signal),   id: ".compute_return_signal",    after: "task_wrap.call_task"
      end

      {
        task:      task,
        id:        id,
        extension: [Trailblazer::V2_1::Activity::TaskWrap::Merge.new(task_wrap_extensions)],
        outputs:   operation.outputs
      }
    end

    # @private
    module Nested
      # DISCUSS: use builders here?
      def self.build(nested_operation)
        return dynamic = Dynamic.new(nested_operation), dynamic, true unless nestable_object?(nested_operation)

        # The returned {Nested} instance is a valid circuit element and will be `call`ed in the circuit.
        # It simply returns the nested activity's `signal,options,flow_options` return set.
        # The actual wiring - where to go with that - is done by the step DSL.
        return Trailblazer::V2_1::Operation::Callable(nested_operation, call: :__call__), nested_operation, false
      end

      def self.nestable_object?(object)
        object.is_a?( Trailblazer::V2_1::Activity::Interface )
      end

      def self.operation_class
        Operation
      end

      # For dynamic `Nested`s that do not expose an {Activity} interface.
      # Since we do not know its outputs, we have to map them to :success and :failure, only.
      #
      # This is what {Nested} in 2.0 used to do, where the outcome could only be true/false (or success/failure).
      class Dynamic
        def initialize(nested_activity)
          @nested_activity = Trailblazer::V2_1::Option::KW(nested_activity)
          @outputs         = {
            :success => Activity::Output( Railway::End::Success.new(semantic: :success), :success ),
            :failure => Activity::Output( Railway::End::Failure.new(semantic: :failure), :failure ),
          }
        end

        attr_reader :outputs

        # TaskWrap step.
        def compute_nested_activity((wrap_ctx, original_args), **circuit_options)
          (ctx,), original_circuit_options = original_args

          # TODO: evaluate the option to get the actual "object" to call.
          activity = @nested_activity.call(ctx, original_circuit_options)

          # Overwrite :task so task_wrap.call_task will call this activity.
          # This is a trick so we don't have to repeat logic from #call_task here.
          wrap_ctx[:task] = Trailblazer::V2_1::Operation::Callable( activity, call: :__call__ )

          return Activity::Right, [wrap_ctx, original_args]
        end

        def compute_return_signal((wrap_ctx, original_args), **circuit_options)
          # Translate the genuine nested signal to the generic Dynamic end (success/failure, only).
          # Note that here we lose information about what specific event was emitted.
          wrap_ctx[:return_signal] = wrap_ctx[:return_signal].kind_of?(Railway::End::Success) ?
            @outputs[:success].signal : @outputs[:failure].signal

          return Activity::Right, [wrap_ctx, original_args]
        end
      end
    end
  end
end
