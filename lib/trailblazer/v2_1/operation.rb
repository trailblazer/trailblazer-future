require "forwardable"

# trailblazer-context
require "trailblazer/v2_1/option"
require "trailblazer/v2_1/context"
require "trailblazer/v2_1/container_chain"

require "trailblazer/v2_1/activity"
require "trailblazer/v2_1/activity/dsl/magnetic"


require "trailblazer/v2_1/operation/variable_mapping"
require "trailblazer/v2_1/operation/callable"

require "trailblazer/v2_1/operation/heritage"
require "trailblazer/v2_1/operation/public_call"      # TODO: Remove in 3.0.
require "trailblazer/v2_1/operation/class_dependencies"
require "trailblazer/v2_1/operation/deprecated_macro" # TODO: remove in 2.2.
require "trailblazer/v2_1/operation/result"
require "trailblazer/v2_1/operation/railway"

require "trailblazer/v2_1/operation/railway/fast_track"
require "trailblazer/v2_1/operation/railway/normalizer"
require "trailblazer/v2_1/operation/trace"

require "trailblazer/v2_1/operation/railway/macaroni"

module Trailblazer::V2_1
  # The Trailblazer::V2_1-style operation.
  # Note that you don't have to use our "opinionated" version with result object, skills, etc.
  class Operation

    module FastTrackActivity
      builder_options = {
        track_end:     Railway::End::Success.new(semantic: :success),
        failure_end:   Railway::End::Failure.new(semantic: :failure),
        pass_fast_end: Railway::End::PassFast.new(semantic: :pass_fast),
        fail_fast_end: Railway::End::FailFast.new(semantic: :fail_fast),
      }

      extend Activity::FastTrack( pipeline: Railway::Normalizer::Pipeline, builder_options: builder_options )
    end

    extend Skill::Accessors        # ::[] and ::[]= # TODO: fade out this usage.

    def self.inherited(subclass)
      super
      subclass.initialize!
      heritage.(subclass)
    end

    def self.initialize!
      @activity = FastTrackActivity.clone
    end


    extend Activity::Interface

    module Process
      def to_h
        @activity.to_h.merge( activity: @activity )
      end
    end

    extend Process # make ::call etc. class methods on Operation.

    extend Heritage::Accessor

    class << self
      extend Forwardable # TODO: test those helpers
      def_delegators :@activity, :Path, :Output, :End, :Track
      def_delegators :@activity, :outputs

      def step(task, options={}, &block); add_task!(:step, task, options, &block) end
      def pass(task, options={}, &block); add_task!(:pass, task, options, &block) end
      def fail(task, options={}, &block); add_task!(:fail, task, options, &block) end

      alias_method :success, :pass
      alias_method :failure, :fail

      def add_task!(name, task, options, &block)
        heritage.record(name, task, options, &block)
        @activity.send(name, task, options, &block)
      end
    end

    extend PublicCall              # ::call(params, { current_user: .. })
    extend Trace                   # ::trace
  end
end

require "trailblazer/v2_1/operation/inspect"
