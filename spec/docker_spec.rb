require 'docker'

describe "Docker image building" do

  RSpec.configure do |config|

    config.after :suite do
      $container.remove force: true
    end

  end

  before :all do
    Excon.defaults[:write_timeout] = 90000
    Excon.defaults[:read_timeout]  = 90000
  end

  context "docker is working" do

    it "should have an URL" do
      expect(Docker.url).to_not be_nil
    end

    it "should have version information" do
      expect(Docker.version).to_not be_nil
    end

    it "version should be newer or equal to 1.3.0" do
      Gem::Version.new(Docker::version["Version"]) >= Gem::Version.new('1.3.0')
    end

    it "API version should be newer or equal to 15" do
      Gem::Version.new(Docker::version["ApiVersion"]) >= Gem::Version.new('15')
    end

  end

  context "building test image" do

      it "should successfully build application image" do
        $image = Docker::Image.build_from_dir "."
        expect($image).to_not be_nil
      end

      it "new image should exist" do
        expect(Docker::Image.exist? $image.id).to eql true
      end

  end

  context "creating and starting application container" do

      it "should succeed creating container" do
        $container = Docker::Container.create Image: $image.id
        expect($container).to_not be_nil
      end

      it "should run container" do
        expect($container.start PublishAllPorts: true).to_not be_nil
      end

  end

end

