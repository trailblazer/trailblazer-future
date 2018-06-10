class SongsController < ApplicationController
  def new
    run Song::New
  end

  def show
    run Song::Show
  end

  def create
    run Song::Create do
      return redirect_to song_path(@model.id)
    end

    render :new
  end

  def new_with_result
    result = run Song::New

    @class = @model.class
  end

  def edit
    run_v21 Song::Update::Present
  end

  def update
    run_v21 Song::Update do
      return redirect_to song_path(@model.id)
    end

    render :update
  end
end
