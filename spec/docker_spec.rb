require 'docker'

describe "Docker image building" do

  RSpec.configure do |config|

    config.after :suite do
      $container.remove force: true
    end

  end

  context "docker is working" do

    it "should have an url" do
      expect(Docker.url).to_not be_nil
    end

    it "should have version informtaion" do
      expect(Docker.version).to_not be_nil
    end

  end

  context "building test image" do

      it "should succesfully build app image" do
        $image = Docker::Image.build_from_dir "."
        expect($image).to_not be_nil
      end

      it "new image should exist" do
        expect(Docker::Image.exist? $image.id).to eql true
      end

  end

  context "creating and starting app container" do

      it "should succeed creating container" do
        $container = Docker::Container.create Image: $image.id
        expect($container).to_not be_nil
      end

      it "should run container" do
        expect($container.start PublishAllPorts: true).to_not be_nil
      end

  end

end

