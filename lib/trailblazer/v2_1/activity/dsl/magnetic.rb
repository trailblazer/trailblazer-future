module Trailblazer::V2_1
  class Activity < Module   # all code related to the magnetic building of a circuit hash lives in this namespace.
    module Magnetic
      # PlusPole "radiates" a color that MinusPoles are attracted to.
      #
      # This datastructure is produced by the DSL and sits in an ADDS.
      PlusPole = Struct.new(:output, :color) do
        private :output

        def signal
          output.signal
        end
      end # PlusPole
    end
  end
end

require "trailblazer/v2_1/activity/dsl/magnetic/process_options"
require "trailblazer/v2_1/activity/dsl/magnetic/structure/plus_poles"
require "trailblazer/v2_1/activity/dsl/magnetic/structure/polarization"
require "trailblazer/v2_1/activity/dsl/magnetic/structure/alterations"

require "trailblazer/v2_1/activity/dsl/magnetic"
require "trailblazer/v2_1/activity/dsl/magnetic/builder"
# require "trailblazer/v2_1/activity/dsl/magnetic/builder/dsl_helper"
# require "trailblazer/v2_1/activity/dsl/magnetic/dsl_helper"

require "trailblazer/v2_1/option"
require "trailblazer/v2_1/activity/task_builder"
require "trailblazer/v2_1/activity/dsl/magnetic/builder/default_normalizer"
require "trailblazer/v2_1/activity/dsl/magnetic/builder/path"
require "trailblazer/v2_1/activity/dsl/magnetic/builder/railway"
require "trailblazer/v2_1/activity/dsl/magnetic/builder/fast_track" # TODO: move to Operation gem.

require "trailblazer/v2_1/activity/dsl/magnetic/generate"
require "trailblazer/v2_1/activity/dsl/magnetic/finalizer"
