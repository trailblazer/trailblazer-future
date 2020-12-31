require 'delegate'
require "trailblazer/v2_1/developer"

module Trailblazer::V2_1
  class Operation
    module Trace
      # @note The problem in this method is, we have redundancy with Operation::PublicCall
      def self.call(operation, options)
        ctx = PublicCall.options_for_public_call(options) # redundant with PublicCall::call.

        stack, signal, (ctx, _flow_options) = Developer::Trace.(operation, [ctx, {}])

        result = Railway::Result(signal, ctx) # redundant with PublicCall::call.

        Result.new(result, stack.to_a)
      end

      # `Operation::trace` is included for simple tracing of the flow.
      # It simply forwards all arguments to `Trace.call`.
      #
      # @public
      #
      #   Operation.trace(params, current_user: current_user).wtf
      def trace(options)
        Trace.(self, options)
      end

      # Presentation of the traced stack via the returned result object.
      # This object is wrapped around the original result in {Trace.call}.
      class Result < ::SimpleDelegator
        def initialize(result, stack)
          super(result)
          @stack = stack
        end

        def wtf
          Developer::Trace::Present.(@stack)
        end

        def wtf?
          puts wtf
        end
      end
    end
  end
end
