require 'timeout'
require 'spec_helper'

describe 'Atlassian Confluence instance' do
  include_context 'a buildable docker image', '.' #, Env: ['CATALINA_OPTS=-XX:MaxPermSize=128m']

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
      it { expect(current_path).to match '/setup/setupstart.action' }
      it { is_expected.to have_title 'Set up Confluence - Confluence' }
      it { is_expected.to have_css 'form[name=startform]' }
      it { is_expected.to have_css 'div.confluence-setup-choice-box[setup-type=custom]' }
      # it { is_expected.to have_button 'Next' } # For some reason this does not work
    end

    context 'when processing welcome setup' do
      before :all do
        within 'form[name=startform]' do
          find(:css, 'div.confluence-setup-choice-box[setup-type=custom]').trigger('click')
          click_button 'Next'
        end
      end

      it { expect(current_path).to match '/setup/selectbundle.action' }
      it { is_expected.to have_title 'Get add-ons - Confluence' }
      it { is_expected.to have_content 'Get add-ons' }
      it { is_expected.to have_css 'form#selectBundlePluginsForm' }
      it { is_expected.to have_button 'Next' }
    end

    context 'when processing add-ons setup' do
      before :all do
        within 'form#selectBundlePluginsForm' do
          click_button 'Next'
        end
      end

      it { expect(current_path).to match '/setup/setuplicense.action' }
      it { is_expected.to have_title 'License key - Confluence' }
      it { is_expected.to have_content 'License key' }
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
      # SIGTERM.
      #
      # The following state check has been left out 'ExitCode' => 143 to
      # suppor CircleCI as CI builder. For some reason whether you send SIGTERM
      # or SIGKILL, the exit code is always 0, perhaps it's the container
      # driver
      is_expected.to include_state 'Running' => false
    end

    include_examples 'a clean console'
  end
end
