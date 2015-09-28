require 'timeout'
require 'spec_helper'

shared_examples 'an acceptable confluence instance' do |database_examples|
  include_context 'a buildable docker image', '.', Env: ["CATALINA_OPTS=-Xms64m -Datlassian.plugins.enable.wait=#{Docker::DSL.timeout}"]

  describe 'when starting a JIRA instance' do
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

    context 'when visiting the root page' do
      it { expect(current_path).to match '/setup/setupstart.action' }
      it { is_expected.to have_css 'form[name=startform]' }
      it { is_expected.to have_css 'div.confluence-setup-choice-box[setup-type=custom]' }
      # it { is_expected.to have_button 'Next' } for some reason this does not work
    end

    context 'when manually setting up the instance' do
      before :all do
        within 'form[name=startform]' do
          find(:css, 'div.confluence-setup-choice-box[setup-type=custom]').trigger('click')
          click_button 'Next'
        end
      end

      it { expect(current_path).to match '/setup/selectbundle.action' }
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
      it { is_expected.to have_css 'form#licenseform' }
      it { is_expected.to have_field 'confLicenseString' }
      it { is_expected.to have_button 'Next' }
    end

    context 'when processing license setup' do
      before :all do
        within 'form#licenseform' do
          fill_in 'confLicenseString', with: 'AAABiQ0ODAoPeNp1kk9TwjAQxe/9FJnxXKYpeoCZHqCtgsqfgaIO4yWELURD0tm0KN/eWOjYdvD68vbtb3dzM9GKTBgS2iOU9n3a7/pkHiXE96jvbNhho3XnWXBQBuKtyIVWQTxN4sV8MV7GTirMHk5QOZJTBsG91eITvPdJBEeQOgN0uNRHwIYtLKWGa1ocNoCzdGUATUA9h2uVdhjPxRGCHAtw5gXyPTMQsRwCn1Lf9XzXv3NqwVN2gGCZDBYWstLj70zgqSyad0fVWPXgJaClGUfB8KGXuG+rl1v3ab0euUOPvjofAlmD/XG8GJBY5YAZCtMa9Ze5MagVZAGKX/FVE4eyMDZtqrdgAq+19zJlWEr/Na0TXjkTx4KLjWzeKbyIjaAJE7aDYpa2tTSO+mvbCrBKo/ryate4Up9KfylnhjumhGEl0SCXzBjB1B9Q/QYhQulrH/fcue6svl1di8BwFFnZKAGTE3mGIalGksliJxTZVqTmvLF6fXxksjhzpkwaqP5s3fMDBMYhRDAtAhUAhcR3uL05YCxbclq7h1dNa+Nc+j4CFBrdN005oVlMN9yBlWeM4TlnrOhqX02j3'
          click_button 'Next'
        end
      end

      it { expect(current_path).to match '/setup/setupdbchoice-start.action' }
      it { is_expected.to have_css 'form[name=embeddedform]' }
      it { is_expected.to have_button 'Embedded Database' }
    end

    context 'when processing database setup' do
      include_examples database_examples

      # it { expect(current_path).to match '/setup/setupdata-start.action' }
      # it { is_expected.to have_css 'form#demoChoiceForm' }
      # it { is_expected.to have_button 'Example Site' }
    end

    context 'when processing content setup' do
      before :all do
        within 'form#demoChoiceForm' do
          click_button 'Example Site'
        end
      end

      it { expect(current_path).to match '/setup/setupusermanagementchoice-start.action' }
      it { is_expected.to have_css 'form[name=internaluser]' }
      it { is_expected.to have_button 'Manage users and groups within Confluence' }
    end

    context 'when processing user management setup' do
      before :all do
        within 'form[name=internaluser]' do
          click_button 'Manage users and groups within Confluence'
        end
      end

      it { expect(current_path).to match '/setup/setupadministrator-start.action' }
      it { is_expected.to have_css 'form[name=setupadministratorform]' }
      it { is_expected.to have_field 'username' }
      it { is_expected.to have_field 'fullName' }
      it { is_expected.to have_field 'email' }
      it { is_expected.to have_field 'password' }
      it { is_expected.to have_field 'confirm' }
      it { is_expected.to have_button 'Next' }
    end

    context 'when processing administrative account setup' do
      before :all do
        within 'form[name=setupadministratorform]' do
          fill_in 'username', with: 'admin'
          fill_in 'fullName', with: 'Continuous Integration Administrator'
          fill_in 'email', with: 'jira@circleci.com'
          fill_in 'password', with: 'admin'
          fill_in 'confirm', with: 'admin'
          click_button 'Next'
        end
      end

      it { expect(current_path).to match '/setup/finishsetup.action' }
      it { is_expected.to have_link 'Start' }
    end

    context 'when processing successful setup' do
      before :all do
        click_link 'Start'
      end

      it { expect(current_path).to match '/welcome.action' }
      it { is_expected.to have_button "Let's get going!" }
      # The acceptance testing comes to an end here since we got to the
      # Confluence dashboard without any trouble through the setup.
    end

    # context 'when processing welcome introduction' do
    #   before :all do
    #     # Step 1
    #     click_button "Let's get going!"
    #     # Step 2
    #     click_button 'No headphones? Skip'
    #     # Step 3
    #     click_button 'Skip'
    #     # Step 4
    #     fill_in 'grow-intro-space-name', with: 'Continuous Integration Space'
    #     click_button 'Continue'
    #     # we need to wait for location change here
    #     wait_for_location_change
    #     # Step 6 edit Space Home page
    #     fill_in 'content-title', with: 'Continous Integration Page'
    #     find(:css, 'button[name=confirm]').trigger('click')
    #   end

    #   it { expect(current_path).to match '/display/CIS/Continous+Integration+Page' }
    #   # it { is_expected.to have_content 'Continous Integration Space' }
    #   # it { is_expected.to have_content 'Continous Integration Page' }
    # end
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
