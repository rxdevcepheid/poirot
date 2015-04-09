package "git"
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"
include_recipe "instedd-common::passenger"
include_recipe "nodejs"

# Workaround for ubuntu 14.04
# "curl -fsSL https://gist.githubusercontent.com/riocampos/b2669b26016207224f06/raw | rbenv install --patch 2.0.0-p353"
rbenv_ruby "2.0.0-p576"
rbenv_gem "bundler" do
  ruby_version "2.0.0-p576"
end

include_recipe "mysql::client"
include_recipe "database::mysql"

mysql_connection = {
  host: node['mysql']['server_host'],
  username: node['mysql']['admin_username'] || 'root',
  password: node['mysql']['admin_password'] || node['mysql']['server_root_password']
}

mysql_database "poirot" do
  connection mysql_connection
end

rails_web_app "poirot" do
  server_name node['poirot']['host_name']
  server_port node['poirot']['web']['port']
  config_files %w(settings.local.yml database.yml)
  passenger_spawn_method :conservative

  force_ssl node['poirot']['web']['ssl']['force']

  ssl node['poirot']['web']['ssl']['enabled']
  ssl_cert_file node['poirot']['web']['ssl']['cert_file']
  ssl_cert_key_file node['poirot']['web']['ssl']['cert_key_file']
  ssl_cert_chain_file node['poirot']['web']['ssl']['cert_chain_file']
  ssl_port node['poirot']['web']['ssl']['port']

  partials({"poirot/basic_auth.conf.erb" => { cookbook: "poirot" }})
  ssl_partials({"poirot/basic_auth.conf.erb" => { cookbook: "poirot" }})
end

# Configure basic auth
if node['poirot']['web']['auth']
  package 'apache2-utils'
  execute("htpasswd -bc #{node['apache']['dir']}/poirot.htpasswd #{node['poirot']['web']['auth']['user']} #{node['poirot']['web']['auth']['pass']}")
end

# Add poirot port to apache listen ports
unless node['apache']['listen_ports'].include?(node['poirot']['web']['port'])
  node.set['apache']['listen_ports'] = node['apache']['listen_ports'] + [node['poirot']['web']['port']]
end
