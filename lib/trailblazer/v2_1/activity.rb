module Trailblazer::V2_1
  class Activity < Module
    attr_reader :initial_state

    def initialize(implementation, options)
      builder, adds, circuit, outputs, options = BuildState.build_state_for( implementation.config, options)

      @initial_state = State::Config.build(
        builder: builder,
        options: options,
        adds:    adds,
        circuit: circuit,
        outputs: outputs,
      )

      include *options[:extend] # include the DSL methods.
      include PublicAPI
    end

    # Injects the initial configuration into the module defining a new activity.
    def extended(extended)
      super
      extended.instance_variable_set(:@state, initial_state)
    end


    module Inspect
      def inspect
        "#<Trailblazer::V2_1::Activity: {#{name || self[:options][:name]}}>"
      end

      alias_method :to_s, :inspect
    end


    require "trailblazer/v2_1/activity/dsl/helper"
    # Helpers such as Path, Output, End to be included into {Activity}.
    module DSLHelper
      extend Forwardable
      def_delegators :@builder, :Path
      def_delegators DSL, :Output, :End, :Subprocess, :Track

      def Path(*args, &block)
        self[:builder].Path(*args, &block)
      end
    end

    # Reader and writer method for DSL objects.
    # The writer {dsl[:key] = "value"} exposes immutable behavior and will replace the old
    # @state with a new, modified copy.
    #
    # Always use the DSL::Accessor accessors to avoid leaking state to other components
    # due to mutable write operations.
    module Accessor
      def []=(*args)
        @state = State::Config.send(:[]=, @state, *args)
      end

      def [](*args)
        State::Config[@state, *args]
      end
    end

    # FIXME: still to be decided
    # By including those modules, we create instance methods.
    # Later, this module is `extended` in Path, Railway and FastTrack, and
    # imports the DSL methods as class methods.
    module PublicAPI
      include Accessor

    require "trailblazer/v2_1/activity/dsl/add_task"
      include DSL::AddTask

    require "trailblazer/v2_1/activity/interface"
      include Activity::Interface # DISCUSS

      include DSLHelper # DISCUSS

      include Activity::Inspect # DISCUSS

    require "trailblazer/v2_1/activity/dsl/magnetic/merge"
      include Magnetic::Merge # Activity#merge!

      # @private Note that {Activity.call} is considered private until the public API is stable.
      def call(args, circuit_options={})
        self[:circuit].( args, circuit_options.merge(activity: self) )
      end
    end

  end # Activity
end

require "trailblazer/v2_1/circuit"
require "trailblazer/v2_1/activity/structures"
require "trailblazer/v2_1/activity/config"

require "trailblazer/v2_1/activity/dsl/strategy/build_state"
require "trailblazer/v2_1/activity/dsl/strategy/path"
require "trailblazer/v2_1/activity/dsl/strategy/plan"
require "trailblazer/v2_1/activity/dsl/strategy/railway"
require "trailblazer/v2_1/activity/dsl/strategy/fast_track"

require "trailblazer/v2_1/activity/task_wrap"
require "trailblazer/v2_1/activity/task_wrap/call_task"
require "trailblazer/v2_1/activity/task_wrap/trace"
require "trailblazer/v2_1/activity/task_wrap/runner"
require "trailblazer/v2_1/activity/task_wrap/merge"
require "trailblazer/v2_1/activity/task_wrap/variable_mapping"

require "trailblazer/v2_1/activity/trace"
require "trailblazer/v2_1/activity/present"

require "trailblazer/v2_1/activity/introspect"

require "trailblazer/v2_1/activity/dsl/magnetic/builder/state"
require "trailblazer/v2_1/activity/dsl/magnetic" # the "magnetic" DSL

require "trailblazer/v2_1/activity/dsl/schema/sequence"
require "trailblazer/v2_1/activity/dsl/schema/dependencies"

require "trailblazer/v2_1/activity/dsl/magnetic/builder/normalizer" # DISCUSS: name and location are odd. This one uses Activity ;)

require "trailblazer/v2_1/activity/dsl/record"
