require 'timeout'
require 'spec_helper'

describe 'Atlassian Confluence instance' do
  include_context 'a buildable docker image', '.', Env: ['CATALINA_OPTS=-Xms64m']

  describe 'when starting a Confluence instance' do
    before(:all) { @container.start! PublishAllPorts: true }

    it { is_expected.to_not be_nil }
    it { is_expected.to be_running }
    it { is_expected.to have_mapped_ports tcp: 8090 }
    it { is_expected.not_to have_mapped_ports udp: 8090 }
    it { is_expected.to wait_until_output_matches REGEX_STARTUP }
  end

  describe 'Going through the setup process' do
    before :all do
      @container.setup_capybara_url tcp: 8090
      visit '/'
    end

    subject { page }

    context 'when visiting root page' do
      it { expect(current_path).to match %r{^/setup/setupstart.action} }
      it { is_expected.to have_title 'Welcome - Confluence' }
      it { is_expected.to have_content 'Welcome' }
      it { is_expected.to have_content 'Production Installation' }
      it { is_expected.to have_button 'Start setup' }
    end

    context 'when processing welcome setup' do
      before :all do
        within 'form[name=startform]' do
          click_button 'Start setup'
        end
      end

      it { expect(current_path).to match %r{^/setup/setuplicense.action} }
      it { is_expected.to have_content 'Confluence Setup Wizard' }
      it { is_expected.to have_content 'Enter License' }
    end

    context 'when processing license setup' do
      # there's not much we can do from here from a CI point of view,
      # unless there exists a universal trial license which would work
      # with all possible Server ID's.
    end
  end

  describe 'Stopping the Confluence instance' do
    before(:all) { @container.kill_and_wait signal: 'SIGTERM' }

    it 'should shut down successful' do
      # give the container up to 5 minutes to successfully shutdown
      # exit code: 128+n Fatal error signal "n", ie. 143 = fatal error signal
      # SIGTERM
      is_expected.to include_state 'ExitCode' => 143, 'Running' => false
    end

    include_examples 'a clean console'
  end
end
