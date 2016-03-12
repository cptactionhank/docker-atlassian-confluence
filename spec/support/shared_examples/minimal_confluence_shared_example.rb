shared_examples 'a minimal acceptable Confluence instance' do
  describe 'when testing the web interface' do
    before :all do
      visit '/'
    end

    context 'when visiting the root page' do
      it { expect(current_path).to match '/setup/setupstart.action' }
    end
  end
end
