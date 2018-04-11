# TODO: REMOVE IN 2.2.
module Trailblazer::V2_1
  module Operation::DeprecatedMacro
    # Allows old macros with the `(input, options)` signature.
    def self.call(proc, options)
      warn %{[Trailblazer::V2_1] Macros with API (input, options) are deprecated. Please use the "Task API" signature (options, flow_options) or use a simpler Callable. (#{proc})}

      wrapped_proc = ->( (options, flow_options), **circuit_options ) do
        result = proc.(circuit_options[:exec_context], options) # run the macro, with the deprecated signature.

        direction = Activity::TaskBuilder::Binary.binary_direction_for(result, Activity::Right, Activity::Left)

        return direction, [options, flow_options]
      end

      options.merge( task: wrapped_proc )
    end
  end
end
