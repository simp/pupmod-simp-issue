require 'spec_helper_acceptance'

test_name 'issue class'

describe 'issue class' do
  let(:manifest) do
    <<-EOS
      class { 'issue': }
    EOS
  end

  hosts.each do |host|
    context "on #{host}" do
      it 'applies successfully' do
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end
    end
  end
end
