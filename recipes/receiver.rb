include_recipe "golang"

case node['platform']
when 'ubuntu'
  package "uuid-dev"
  include_recipe "zeromq"
when 'redhat'
  package "zeromq-devel"
else
  raise "Unsupported platform: #{node['platform']}"
end

service "poirot_receiver" do
  provider Chef::Provider::Service::Upstart
end

template "poirot_receiver.conf" do
  path "/etc/init/poirot_receiver.conf"
  source "poirot_receiver.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :stop, "service[poirot_receiver]"
  notifies :start, "service[poirot_receiver]"
end

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
