class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def _run_options(options)
    options.merge("current_user" => "user_name" )
  end

  private

  class Rails::Form < SimpleDelegator
    def initialize(delegated, model_class)
      super(delegated)
      @model_class = model_class
    end

    def self.name
      # for whatever reason, validations climb up the inheritance tree and require _every_ class to have a name (4.1).
      "Reform::Form"
    end

    def model_name
      ::ActiveModel::Name.new(self, nil, @model_class.to_s.camelize)
    end

    def to_model
      self
    end
  end

  module Trailblazer::V2_1
    class Rails::Form < SimpleDelegator
      def initialize(delegated, model_class)
        super(delegated)
        @model_class = model_class
      end

      def self.name
        # for whatever reason, validations climb up the inheritance tree and require _every_ class to have a name (4.1).
        "Reform::Form"
      end

      def model_name
        ::ActiveModel::Name.new(self, nil, @model_class.to_s.camelize)
      end

      def to_model
        self
      end
    end
  end
end
