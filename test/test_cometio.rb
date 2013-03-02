require File.expand_path 'test_helper', File.dirname(__FILE__)

class TestCometio < MiniTest::Unit::TestCase

  def setup
    @client = CometIO::Client.new("http://localhost:5000/cometio/io").connect
  end

  def test_echo
    post_data = {:time => Time.now.to_s, :msg => 'hello!!'}
    res = nil
    @client.on :echo do |data|
      res = data
    end

    @client.on :connect do |session|
      push :to_all, post_data
    end

    30.times do
      break if res != nil
      sleep 0.1
    end
    assert res != nil, 'server not respond'
    assert res["time"] == post_data[:time]
    assert res["msg"] == post_data[:msg]
  end

end
