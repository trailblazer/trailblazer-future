require 'test_helper.rb'

class SongCreateTest < MiniTest::Spec

  let(:result) { Song::Create.({ title: 'Song Title' }, "current_user" => 'user_name' ) }

  it { result.success? }
  it { result['model'].title == 'Song Title' }
  it { result['model'].user_name == 'user_name' }
end

