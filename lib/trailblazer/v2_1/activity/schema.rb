module Trailblazer::V2_1
  class Activity
    NodeAttributes = Struct.new(:id, :outputs, :task, :data)

    # Schema is primitive data structure + an invoker (usually coming from Activity etc)
    class Schema < Struct.new(:circuit, :outputs, :nodes, :config)

      # @!method to_h()
      #   Returns a hash containing the schema's components.

    end # Schema
  end
end
require "trailblazer/v2_1/activity/schema/implementation"
require "trailblazer/v2_1/activity/schema/intermediate"
