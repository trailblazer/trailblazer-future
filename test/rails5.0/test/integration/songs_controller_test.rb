require "test_helper"

class SongsControllerTest < Trailblazer::Test::Integration
  let(:song) do
    Song::Create.(
      { title: 'Song Title' },
      "current_user" => 'user_name'
    )["model"]
  end

  it "new" do
    visit "/songs/new"
    page.must_have_css "form.new_song[action='/songs']"
  end

  it "show" do
    visit "/songs/#{song.id}"
    page.must_have_css "h1", visible: "Skin Trade"
  end

  it "create" do
    visit "/songs/new"
    fill_in "song_title", with: "Out Of My Mind"
    click_button "Create Song"
    page.must_have_css "h1", visible: "Skin Trade"
  end

  it "new_with_result" do
    visit "/songs/new_with_result"
    page.must_have_css "h1", visible: "Song"
  end

  it 'update' do
    visit "songs/#{song.id}/edit"

    fill_in "song_title", with: "Out Of My Mind"
    click_button "Update Song"
    page.must_have_css "h1", visible: "Skin Trade"
  end
end
