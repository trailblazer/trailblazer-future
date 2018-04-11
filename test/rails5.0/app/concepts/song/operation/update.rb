class Song::Update < Trailblazer::V2_1::Operation
  class Present < Trailblazer::V2_1::Operation
    step Model(Song, :find_by)
    step Contract::Build(constant: Song::Contract::Form)
    step Policy::Guard(:policy)

    def policy(_options, model:, current_user:, **)
      model.user_name == current_user
    end
  end

  step Nested(Present)
  step Contract::Validate()
  step Contract::Persist()
end
