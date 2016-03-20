shared_examples 'using an embedded database' do
  before :all do
    within 'form[name=embeddedform]' do
      click_button 'Embedded Database'
    end
  end

  it { is_expected.to have_current_path %r{/setup/setupdata-start.action} }
  it { is_expected.to have_css 'form#demoChoiceForm' }
  it { is_expected.to have_button 'Example Site' }
end
