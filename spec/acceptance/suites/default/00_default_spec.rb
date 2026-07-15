require 'spec_helper_acceptance'

test_name 'issue class'

describe 'issue class' do
  let(:manifest) do
    <<-EOS
      class { 'issue': }
    EOS
  end

  hosts.each do |host|
    # On a fresh node the Sicura console previews this module with
    # `puppet apply --noop`, which must not error. Exercise that here before
    # the real applies below. No package-removal step: issue manages config
    # files only, so noop-only is the representative check (as with fips).
    context 'in noop mode from a clean state' do
      it 'applies without errors in noop mode' do
        apply_manifest_on(host, manifest, catch_failures: true, noop: true)
      end
    end

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
