require 'spec_helper'

describe 'issue', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'When nothing is specified' do
        it do
          is_expected.to contain_File('/etc/issue').with(
            ensure: 'file',
            content: %r{ATTENTION},
          )
          is_expected.to contain_File('/etc/issue.net').with(
            ensure: 'file',
            source: 'file:///etc/issue',
          )
        end
      end

      context 'When profile is specified' do
        let(:params) do
          {
            profile: 'us/department_of_commerce'
          }
        end

        it do
          is_expected.to contain_File('/etc/issue').with(
            ensure: 'file',
            content: %r{Department of Commerce}i,
          )
        end
      end

      context 'When content is specified' do
        let(:params) do
          {
            content: 'Hello!'
          }
        end

        it do
          is_expected.to contain_File('/etc/issue').with(
            ensure: 'file',
            content: 'Hello!',
          )
        end
      end

      context 'When source is specified' do
        let(:params) do
          {
            source: 'puppet:///modules/site/etc/issue'
          }
        end

        it do
          is_expected.to contain_File('/etc/issue').only_with(
            ensure: 'file',
            mode: '0644',
            owner: 'root',
            group: 'root',
            source: 'puppet:///modules/site/etc/issue',
          )
        end
      end

      context 'When net_link is true' do
        let(:params) do
          {
            net_link: true
          }
        end

        it do
          is_expected.to contain_File('/etc/issue').with(
            ensure: 'file',
            content: %r{ATTENTION},
          )
          is_expected.to contain_File('/etc/issue.net').with(
            ensure: 'file',
            source: 'file:///etc/issue',
          )
        end
      end

      context 'When net_link is false and net_content is specified' do
        let(:params) do
          {
            net_link: false,
            net_content: 'Hello!'
          }
        end

        it do
          is_expected.to contain_File('/etc/issue').with(
            ensure: 'file',
            content: %r{ATTENTION},
          )
          is_expected.to contain_File('/etc/issue.net').with(
            ensure: 'file',
            content: 'Hello!',
          )
        end
      end

      context 'When net_link is false and net_content is not specified' do
        let(:params) do
          {
            net_link: false
          }
        end

        it do
          expect { is_expected.to compile }.to raise_error(%r{needs to be provided})
        end
      end
    end
  end
end
