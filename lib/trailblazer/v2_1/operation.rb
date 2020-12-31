require 'forwardable'

require "trailblazer/v2_1/option"
require "trailblazer/v2_1/context"

require "trailblazer/v2_1/activity/dsl/linear"

module Trailblazer::V2_1
  # DISCUSS: I don't know where else to put this. It's not part of the {Activity} concept
  class Activity
    class Railway
      module End
        # @private
        class Success < Activity::End; end
        class Failure < Activity::End; end

        class FailFast < Failure; end
        class PassFast < Success; end
      end
    end

    module Operation
      def self.OptionsForState()
        {
          end_task:      Activity::Railway::End::Success.new(semantic: :success),
          failure_end:   Activity::Railway::End::Failure.new(semantic: :failure),
          fail_fast_end: Activity::Railway::End::FailFast.new(semantic: :fail_fast),
          pass_fast_end: Activity::Railway::End::PassFast.new(semantic: :pass_fast),
        }
      end
    end
  end

  def self.Operation(options)
    Class.new(Activity::FastTrack( Activity::Operation.OptionsForState.merge(options) )) do
      extend Operation::PublicCall
    end
  end

  # The Trailblazer::V2_1-style operation.
  # Note that you don't have to use our "opinionated" version with result object, skills, etc.
  class Operation < Activity::FastTrack(Activity::Operation.OptionsForState)
    # extend Skill::Accessors # ::[] and ::[]= # TODO: fade out this usage.

    class << self
      alias_method :strategy_call, :call
    end

    require "trailblazer/v2_1/operation/public_call"      # TODO: Remove in 3.0.
    extend PublicCall              # ::call(params, { current_user: .. })

    require "trailblazer/v2_1/operation/trace"
    extend Trace                   # ::trace
  end
end

require "trailblazer/v2_1/operation/class_dependencies"
require "trailblazer/v2_1/operation/deprecated_macro" # TODO: remove in 2.2.

require "trailblazer/v2_1/operation/result"
require "trailblazer/v2_1/operation/railway"

require "trailblazer/v2_1/operation/railway/macaroni"
