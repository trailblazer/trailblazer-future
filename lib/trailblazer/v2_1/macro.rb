require "forwardable"
require "trailblazer/v2_1/activity"
require "trailblazer/v2_1/activity/dsl/linear"
require "trailblazer/v2_1/operation" # TODO: remove this dependency

require "trailblazer/v2_1/macro/model"
require "trailblazer/v2_1/macro/policy"
require "trailblazer/v2_1/macro/guard"
require "trailblazer/v2_1/macro/pundit"
require "trailblazer/v2_1/macro/nested"
require "trailblazer/v2_1/macro/rescue"
require "trailblazer/v2_1/macro/wrap"

module Trailblazer::V2_1
  module Macro
  end

  # All macros sit in the {Trailblazer::V2_1::Macro} namespace, where we forward calls from
  # operations and activities to.
  module Activity::DSL::Linear::Helper
    Policy = Trailblazer::V2_1::Macro::Policy

    module ClassMethods
      extend Forwardable
      def_delegators Trailblazer::V2_1::Macro, :Model, :Nested, :Wrap, :Rescue
    end # ClassMethods
  end # Helper
end
