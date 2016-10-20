shared_examples 'using a PostgreSQL database' do
  before :all do
    within 'form[name=standardform]' do
      select 'PostgreSQL', from: 'dbChoiceSelect'
      click_button 'External Database'
      wait_for_page
    end
  end

  it { is_expected.to have_button 'Direct JDBC' }

  describe 'setting up Direct JDBC Connection' do
    before :all do
      click_button 'Direct JDBC'
      wait_for_page
    end

    it { is_expected.to have_css 'form[name=dbform]' }
    it { is_expected.to have_field 'dbConfigInfo.databaseUrl' }
    it { is_expected.to have_field 'dbConfigInfo.userName' }
    it { is_expected.to have_field 'dbConfigInfo.password' }
    it { is_expected.to have_button 'Next' }
  end

  describe 'setting up JDBC Configuration' do
    before :all do
      within 'form[name=dbform]' do
        fill_in 'dbConfigInfo.databaseUrl', with: "jdbc:postgresql://#{@container_db.host}:5432/confluencedb"
        fill_in 'dbConfigInfo.userName', with: 'postgres'
        fill_in 'dbConfigInfo.password', with: 'mysecretpassword'
        click_button 'Next'
        wait_for_page
      end
    end

    it { is_expected.to have_current_path %r{/setup/setupdata-start.action} }
    it { is_expected.to have_css 'form#demoChoiceForm' }
    it { is_expected.to have_button 'Example Site' }
  end
end
