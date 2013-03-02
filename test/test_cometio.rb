require File.expand_path 'test_helper', File.dirname(__FILE__)

class TestCometio < MiniTest::Unit::TestCase

  def setup
    api_url = "http://localhost:5000/cometio/io"
    app_dir = File.expand_path 'app', File.dirname(__FILE__)
    pid_file = "/tmp/sinatra-cometio-test-pid"
    File.delete pid_file if File.exists? pid_file
    Thread.new do
      IO::popen "cd #{app_dir} && PID_FILE=#{pid_file} rackup config.ru -p 5000"
    end
    100.times do
      break if File.exists? pid_file
      sleep 0.1
    end
    File.open(pid_file) do |f|
      @pid = f.gets.strip
    end
    sleep 3
    @client = CometIO::Client.new(api_url).connect
  end

  def test_echo_all
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
    system "kill #{@pid}"
  end

end
