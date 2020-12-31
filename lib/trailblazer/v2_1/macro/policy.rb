module Trailblazer::V2_1::Macro
  module Policy
    # Step: This generically `call`s a policy and then pushes its result to `options`.
    # You can use any callable object as a policy with this step.
    class Eval
      def initialize(name: nil, path: nil)
        @name = name
        @path = path
      end

      # incoming low-level {Task API}.
      # outgoing Task::Binary API.
      def call((options, flow_options), **circuit_options)
        condition = options[@path] # this allows dependency injection.
        result    = condition.([options, flow_options], **circuit_options)

        options[:"policy.#{@name}"]        = result[:policy] # assign the policy as a skill.
        options[:"result.policy.#{@name}"] = result

        # flow control
        signal = result.success? ? Trailblazer::V2_1::Activity::Right : Trailblazer::V2_1::Activity::Left # since we & this, it's only executed OnRight and the return boolean decides the direction, input is passed straight through.

        return signal, [options, flow_options]
      end
    end

    # Adds the `yield` result to the pipe and treats it like a
    # policy-compatible  object at runtime.
    def self.step(condition, options, &block)
      name = options[:name]
      path = :"policy.#{name}.eval"

      task = Eval.new(name: name, path: path)

      injection = Trailblazer::V2_1::Activity::TaskWrap::Inject::Defaults::Extension(
        path => condition
      )

      {task: task, id: path, extensions: [injection]}
    end
  end
end
