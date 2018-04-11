require 'test_helper.rb'

class SongUpdateTest < MiniTest::Spec
  let(:song) do
    Song::Create.(
      { title: 'Song Title' },
      "current_user" => 'user_name'
    )
  end

  let(:result) do
    Song::Update.(
      params: {
        id: song['model'].id,
        title: 'New Song Title'
      },
      current_user: current_user
    )
  end

  describe 'when user cannot update song' do
    let(:current_user) { 'wrong'}

    it { result.failure? }
  end

  describe 'when user cannot update song' do
    let(:current_user) { 'user_name'}

    it { result.failure? }
    it { result[:model].title == 'New Song Title' }
  end
end

