require "trailblazer/v2_1/activity"
require "trailblazer/v2_1/activity/dsl/linear"

require "trailblazer/v2_1/macro/contract/build"
require "trailblazer/v2_1/macro/contract/validate"
require "trailblazer/v2_1/macro/contract/persist"

module Trailblazer::V2_1
  module Macro
    module Contract
    end
  end

  # All macros sit in the {Trailblazer::V2_1::Macro::Contract} namespace, where we forward calls from
  # operations and activities to.
  module Activity::DSL::Linear::Helper
    Contract = Macro::Contract
  end
end
