include_recipe "golang"

# Install deps
case node['platform']
when 'ubuntu'
  package "uuid-dev"
  include_recipe "zeromq"
when 'redhat'
  package "zeromq-devel"
else
  raise "Unsupported platform: #{node['platform']}"
end

# Create user to run service
user node['poirot']['receiver']['user']

# Register service in chef
service "poirot_receiver" do
  provider Chef::Provider::Service::Upstart
end

# Set up upstart configuration
template "poirot_receiver.conf" do
  path "/etc/init/poirot_receiver.conf"
  source "poirot_receiver.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :stop, "service[poirot_receiver]"
  notifies :start, "service[poirot_receiver]"
  variables logdir: "/opt/poirot_receiver/shared/log", user: node['poirot']['receiver']['user']
end

# Configure receiver logs in upstart
logrotate_app "poirot_receiver" do
  path "/opt/poirot_receiver/shared/log/*.log"
  frequency :daily
  rotate 7
  options %w(missingok compress delaycompress notifempty copytruncate)
end

# Deploy poirot receiver application
deploy_revision "/opt/poirot_receiver" do
  repo "https://bitbucket.org/instedd/poirot_receiver.git"
  create_dirs_before_symlink []
  purge_before_symlink []
  symlink_before_migrate({})
  symlinks({})
  before_restart do
    bash "make" do
      cwd release_path
      flags "--login"
      code "make"
    end
  end
  notifies :restart, "service[poirot_receiver]"
end

# Allow conncetions to poirot receiver
simple_iptables_rule "poirot_receiver" do
  rule "--proto tcp --dport #{node['poirot']['receiver']['port']}"
  jump "ACCEPT"
end
