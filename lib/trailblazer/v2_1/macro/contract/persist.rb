module Trailblazer::V2_1
  module Macro
    module Contract
      def self.Persist(method: :save, name: "default")
        path = :"contract.#{name}"
        step = ->(options, **) { options[path].send(method) }

        task = Activity::TaskBuilder::Binary(step)

        {task: task, id: "persist.save"}
      end
    end
  end
end
