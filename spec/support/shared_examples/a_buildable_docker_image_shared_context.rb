shared_examples 'a buildable Docker image' do |path, options = {}|
  before :all do
    image = Docker::Image.build_from_dir(path)
    container_options = { Image: image.id }.merge options
    @container = Docker::Container.create container_options
    @container.start! PublishAllPorts: true
    @container.setup_capybara_url tcp: 8090
  end

  describe 'when starting a Confluence container' do
    subject { @container }

    it { is_expected.to_not be_nil }
    # it { is_expected.to be_running }
    it { is_expected.to have_mapped_ports tcp: 8090 }
    it { is_expected.not_to have_mapped_ports udp: 8090 }
    it { is_expected.to wait_until_output_matches REGEX_STARTUP }
  end

  after :all do
      @container.kill signal: 'SIGKILL' unless @container.nil?
      @container.remove force: true, v: true unless @container.nil? || ENV['CIRCLECI']
  end
end
