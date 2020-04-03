# frozen_string_literal: true

control 'openldap client configuration' do
  title 'should match desired lines'

  client_config =
    case platform[:family]
    when 'debian'
      '/etc/ldap.conf'
    when 'bsd'
      '/usr/local/etc/openldap/ldap.conf'
    else
      '/etc/openldap/ldap.conf'
    end

  describe file(client_config) do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'BASE    dc=example,dc=com' }
    its('content') { should include 'URI    ldap://ldap.example.com' }
  end
end

control 'openldap server configuration' do
  title 'should match desired lines'

  server_config, owned_and_grouped =
    case platform[:family]
    when 'debian'
      %w[/etc/ldap/slapd.conf openldap]
    when 'bsd'
      %w[/usr/local/etc/openldap/slapd.conf ldap]
    else
      %w[/etc/openldap/slapd.conf ldap]
    end

  describe file(server_config) do
    it { should be_file }
    it { should be_owned_by owned_and_grouped }
    it { should be_grouped_into owned_and_grouped }
    its('mode') { should cmp '0644' }
    its('content') { should include 'rootdn		"cn=root,dc=example,dc=com"' }
    its('content') { should include 'rootpw		{SSHA}5++yqs7UNz22kAYf7jboAmklhavVXahK' }
  end
end

control 'openldap defaults configuration' do
  title 'should match desired lines'

  grouped =
    case platform[:family]
    when 'bsd'
      'wheel'
    else
      'root'
    end

  describe file('/etc/default/slapd') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into grouped }
    its('mode') { should cmp '0644' }
    its('content') do
      should include(
        'SLAPD_SERVICES="ldap://127.0.0.1:389/ ldaps:/// ldapi:///"'
      )
    end
    its('content') { should include 'SLAPD_OPTIONS="-4"' }
  end
end