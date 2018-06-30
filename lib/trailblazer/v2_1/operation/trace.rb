module Trailblazer::V2_1
  class Operation
    module Trace
      # @note The problem in this method is, we have redundancy with Operation::PublicCall
      def self.call(operation, *args)
        ctx = PublicCall.options_for_public_call(*args)   # redundant with PublicCall::call.

        # Prepare the tracing-specific arguments. This is only run once for the entire circuit!
        operation, *args = Trailblazer::V2_1::Activity::Trace.arguments_for_call( operation, [ctx, {}], {} )

        last_signal, (ctx, flow_options) = Activity::TaskWrap.invoke(operation, *args )

        result = Railway::Result(last_signal, ctx)    # redundant with PublicCall::call.

        Result.new(result, flow_options[:stack].to_a)
      end

      # `Operation::trace` is included for simple tracing of the flow.
      # It simply forwards all arguments to `Trace.call`.
      #
      # @public
      #
      #   Operation.trace(params, "current_user" => current_user).wtf
      def trace(*args)
        Trace.(self, *args)
      end

      # Presentation of the traced stack via the returned result object.
      # This object is wrapped around the original result in {Trace.call}.
      class Result < SimpleDelegator
        def initialize(result, stack)
          super(result)
          @stack = stack
        end

        def wtf
          Trailblazer::V2_1::Activity::Trace::Present.(@stack)
        end

        def wtf?
          puts wtf
        end
      end
    end
  end
end
