require 'uri'
require 'timeout'
require 'docker'

describe "Atlassian Confluence acceptance" do

  let(:regex_severe)  { /SEVERE|FATAL/  }
  let(:regex_warn)    { /WARNING|WARN/ }
  let(:regex_error)   { /ERROR/   }
  let(:regex_startup) { /Server startup in \d+ ms/ }

  before(:all) do
    @uri = URI.parse Docker.url
    @info = Docker::Container.get($container.id).info rescue nil
    expect(@info).to_not be_nil
  end

  context "when container is running" do

    it "has the container running" do
      expect(@info["State"]).to include("Running" => true)
    end

    it "has port 8090 mapped" do
      port_7990 = @info["NetworkSettings"]["Ports"]["8090/tcp"].first["HostPort"] rescue nil
      expect(port_7990).to_not be_nil
    end

  end

  context "when Atlassian Confluence is running" do

    it "has started" do
      expect {wait_stdout regex_startup}.not_to raise_error
    end

    it "has no severe in the stdout" do
      expect(scan_stdout regex_severe).to be_empty
    end

    it "has no warning in the stdout" do
      expect(scan_stdout regex_warn).to be_empty
    end

    it "has no error in the stdout" do
      expect(scan_stdout regex_error).to be_empty
    end

  end

  context "when Atlassian Confluence is shut down" do

    it "has shut down" do
      # send term signal and expect container to shut down
      $container.kill
      # give the container up to 60 seconds to successfully shutdown
      expect($container.wait 60).to including("StatusCode" => 0, "StatusCode" => -1)
    end

    it "has no severe in the stdout" do
      expect(scan_stdout regex_severe).to be_empty
    end

    it "has no warning in the stdout" do
      expect(scan_stdout regex_warn).to be_empty
    end

    it "has no errors in the stdout" do
      expect(scan_stdout regex_error).to be_empty
    end

  end

end
