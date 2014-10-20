require 'uri'
require 'timeout'
require 'docker'

describe "Atlassian Confluence integration tests" do

  let(:default_timeout) { 90000 }

  before(:all) do
    Excon.defaults[:write_timeout] = 90000
    Excon.defaults[:read_timeout]  = 90000
    # let the container run for short a while before continuing
    sleep 2
    @uri = URI.parse Docker.url
    @info = Docker::Container.get($container.id).info rescue nil
    expect(@info).to_not be_nil
  end

  context "docker container should be up and running" do

      it "should have the container running" do
        expect(@info["State"]).to include("Running" => true)
      end

      it "should have port 8090 (web) mapped" do
        $port_7990 = @info["NetworkSettings"]["Ports"]["8090/tcp"].first["HostPort"] rescue nil
        expect($port_7990).to_not be_nil
      end

  end

  context "confirming Atlassian Confluence is running" do

    it "wait for server is started up" do

      thread = Thread.new do
          Timeout::timeout(default_timeout) do
            Thread.handle_interrupt(TimeoutError => :on_blocking) {
              $container.attach(stream: true, logs: true, stdout: true, stderr: true) do |stream, chunk|
                if ( chunk =~ /Server startup in \d+ ms/ )
                  Thread.current[:success] = true
                  Thread.exit
                end
              end
            }
          end
      end

      thread.join

      expect(thread.key? :success).to eql true

    end

    it "should not have any severe warnings in the stdout logs" do

      thread = Thread.new do
          Timeout::timeout(default_timeout) do
            thread["success"] = []
            Thread.handle_interrupt(TimeoutError => :on_blocking) {
              $container.attach(stream: false, logs: true, stdout: true, stderr: true) do |stream, chunk|
                if ( chunk =~ /SEVERE / )
                  Thread.current[:success] << chunk
                  Thread.exit
                end
              end
            }
          end
      end

      thread.join

      expect(thread[:success]).to be_empty

    end

    it "shutting down the application" do
      # send term signal and expect container to shut down
      $container.kill
      # give the container up to 60 seconds to successfully shutdown
      expect($container.wait 15).to including("StatusCode" => 0, "StatusCode" => -1)
    end

  end

end
