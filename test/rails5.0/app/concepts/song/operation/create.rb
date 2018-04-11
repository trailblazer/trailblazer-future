class Song::New < Trailblazer::Operation
  step Model( Song, :new )
  step Contract::Build(constant: Song::Contract::Form)
  step :set_current_user!

  def set_current_user!(_options, model:, current_user:, **)
    model.user_name = current_user
  end
end

class Song::Create < Trailblazer::Operation
  step Nested( Song::New )
  step Contract::Validate()
  step Contract::Persist()
end
