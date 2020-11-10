describe 'Docker image building' do
  context 'when validating host software' do
    it 'should supported version' do
      expect { Docker.validate_version! }.to_not raise_error
    end
  end

  context 'when building image' do
    subject { Docker::Image.build_from_dir '.' }

    it { is_expected.to_not be_nil }
    it { is_expected.to have_exposed_port tcp: 8090 }
    it { is_expected.to_not have_exposed_port udp: 8090 }
    it { is_expected.to have_exposed_port tcp: 8091 }
    it { is_expected.to_not have_exposed_port udp: 8091 }
    it { is_expected.to have_volume '/var/atlassian/confluence' }
    it { is_expected.to have_volume '/opt/atlassian/confluence/logs' }
    it { is_expected.to have_working_directory '/var/atlassian/confluence' }
  end
end
