include_recipe "erlang::esl"
include_recipe "build-essential"

package "git"
package "zeromq-devel"

remote_file "/usr/local/bin/rebar" do
  source "https://github.com/rebar/rebar/wiki/rebar"
  mode 0755
end

app_dir = "/u/apps/poirot"

# Create user to run the receiver service
user node['poirot']['receiver']['user']

# Create shared and deploy dirs writable by root only
%w(/ /releases/ /shared/).each do |dir|
  directory "#{app_dir}#{dir}" do
    recursive true
  end
end

# Create shared and deploy dirs writable by cepheid receiver user
%w(/shared/log/ /shared/pids/).each do |dir|
  directory "#{app_dir}#{dir}" do
    owner node['poirot']['receiver']['user']
    recursive true
  end
end

template "poirot.config" do
  path "#{app_dir}/shared/poirot.config"
  source "poirot.config.erb"
  owner node['poirot']['receiver']['user']
  mode 0600
end

# Register service in upstart
template "poirot.conf" do
  path "/etc/init/poirot.conf"
  source "poirot.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    user: node['poirot']['receiver']['user'],
    app_dir: app_dir
  )
end

# Configure log rotate for application
logrotate_app "poirot-receiver" do
  path "#{app_dir}/shared/log/*.log"
  frequency :daily
  rotate 7
  options %w(missingok compress delaycompress notifempty copytruncate)
end

# Allow ZMQ port through firewall
simple_iptables_rule "poirot" do
  rule "--proto tcp --dport #{node['poirot']['receiver']['port']}"
  jump "ACCEPT"
end

# Trust bitbucket
ssh_known_hosts_entry "bitbucket.org"

# Deploy receiver application
application "poirot" do
  revision node['poirot']['revision'] if node['poirot']['revision']

  path app_dir
  repository "git@bitbucket.org:instedd/poirot_erlang.git"
  deploy_key data_bag_item('deploy_keys', 'deploy_key')['private_key']
  purge_before_symlink ["log", "tmp"]
  symlinks "log" => "log", "tmp" => "tmp", "poirot.config" => "poirot.config"
  restart_command "sudo stop poirot; sudo start poirot"

  symlink_before_migrate({})
  migrate false

  before_restart do
    bash "make" do
      cwd release_path
      flags "--login"
      code "ln -s . poirot; make"
    end
  end
end

