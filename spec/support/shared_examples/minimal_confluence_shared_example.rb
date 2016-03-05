shared_examples 'a minimal acceptable confluence instance' do

  describe 'when running a JIRA container' do
    it { is_expected.to_not be_nil }
    it { is_expected.to be_running }
    it { is_expected.to have_mapped_ports tcp: 8090 }
    it { is_expected.not_to have_mapped_ports udp: 8090 }
    it { is_expected.to wait_until_output_matches REGEX_STARTUP }
  end

  describe 'Testing the web interface' do
    before :all do
      visit '/'
    end

    subject { page }

    context 'when visiting the root page' do
      it { expect(current_path).to match '/setup/setupstart.action' }
    end

  end

end
