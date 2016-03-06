shared_examples 'a buildable Docker image' do |path, options = {}|
  subject { @container }

  before :all do
    image = Docker::Image.build_from_dir(path)
    container_options = { Image: image.id }.merge options
    @container = Docker::Container.create container_options
    @container.start! PublishAllPorts: true
    @container.setup_capybara_url tcp: 8090
  end

  after :all do
    if ENV['CIRCLECI']
      @container.kill signal: 'SIGKILL'
    else
      @container.remove force: true, v: true
    end
  end

end
