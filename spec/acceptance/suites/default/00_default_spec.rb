require 'spec_helper_acceptance'

test_name 'issue class'

describe 'issue class' do
  let(:manifest) {
    <<-EOS
      class { 'issue': }
    EOS
  }

  hosts.each do |host|
    context "on #{host}" do
      it 'should apply successfully' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end
    end
  end
end
