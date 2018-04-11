class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def run(operation, params=self.params, *dependencies)
    if operation < Trailblazer::Operation
      super
    else
      result = operation.({params: _run_params(self.params) }.merge(*_run_runtime_options(*dependencies)))

      @model = result[:model]
      @form  = Rails::Form.new( result[ "contract.default" ], @model.class )

      yield(result) if result.success? && block_given?

      @_result = result
    end
  end

  private

  def _run_options(options)
    options.merge("current_user" => "user_name" )
  end

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
