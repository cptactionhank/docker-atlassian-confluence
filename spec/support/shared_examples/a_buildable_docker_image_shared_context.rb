shared_examples 'a buildable docker image' do |path, options = {}|
  subject { @container }

  before :all do
    image = Docker::Image.build_from_dir(path)
    container_options = { Image: image.id }.merge options
    @container = Docker::Container.create container_options
    @container.start! PublishAllPorts: true
    @container.setup_capybara_url tcp: 8090
  end

  after :all do
    @container.remove force: true, v: true unless @container.nil? || ENV['CIRCLECI']
  end
end
