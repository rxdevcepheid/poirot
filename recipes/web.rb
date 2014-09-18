# Install ruby and passenger
include_recipe "rbenv_passenger"

rbenv_ruby "2.0.0-p353"
rbenv_gem "bundler" do
  ruby_version "2.0.0-p353"
end

# Create database and mysql user to run the application
include_recipe "database::mysql"

mysql_connection = {
  :host => node['poirot']['mysql']['host'],
  :username => node['poirot']['mysql']['root_name'],
  :password => node['poirot']['mysql']['root_pass']
}

mysql_database node['poirot']['mysql']['dbname'] do
  connection mysql_connection
  action :create
end

[node['poirot']['web']['internal_host']].flatten.each do |host|
  mysql_database_user node['poirot']['mysql']['user_name'] do
    connection    mysql_connection
    password      node['poirot']['mysql']['user_pass']
    privileges    ["DELETE", "INSERT", "SELECT", "UPDATE", "LOCK TABLES"]
    database_name node['poirot']['mysql']['dbname']
    host          host
    action        :grant
  end
end


# Configure webapp
package "nodejs"

app_dir = "/u/apps/poirot-web"
user node['poirot']['web']['user']

poirot_node = node['poirot']

# Trust github
ssh_known_hosts_entry "github.com"

# Deploy web app
application "poirot-web" do
  path app_dir
  repository "https://github.com/instedd/poirot.git"
  revision node['poirot']['web']['revision'] if node['poirot']['web']['revision']
  migrate true
  environment_name "production"
  rollback_on_error false

  environment \
    "SQLADMINUSR" => poirot_node['mysql']['root_name'],
    "SQLADMINPWD" => poirot_node['mysql']['root_pass']

  before_deploy do
    directory("#{app_dir}/shared/log") { owner poirot_node['web']['user'] }

    template "settings.yml" do
      path "#{app_dir}/shared/settings.yml"
      source "settings.yml.erb"
      mode 0664
    end
  end

  before_restart do
    execute("chown -Rf #{poirot_node['web']['user']} #{app_dir}/shared/log")
  end

  rails do
    bundle_command "#{node[:rbenv][:root_path]}/shims/bundle"
    restart_command "touch #{app_dir}/current/tmp/restart.txt"
    bundler true
    precompile_assets true
    symlink_logs true
    migration_command \
      "export SQLADMINUSR=\"#{poirot_node['mysql']['root_name']}\"; " +
      "export SQLADMINPWD=\"#{poirot_node['mysql']['root_pass']}\"; " +
      "if [ `#{node[:rbenv][:root_path]}/shims/bundle exec rake db:version | cut -f2 -d ':'` == 0 ]; " +
      " then #{node[:rbenv][:root_path]}/shims/bundle exec rake db:schema:load db:seed; " +
      " else #{node[:rbenv][:root_path]}/shims/bundle exec rake db:migrate; " +
      "fi; "

    symlink_before_migrate "settings.yml" => "config/settings.local.yml"
    symlinks({})

    database do
      adapter :mysql2
      database poirot_node['mysql']['dbname']
      encoding "utf8"
      reconnect true
      pool 5
      username "<%= ENV['SQLADMINUSR'] || '#{poirot_node['mysql']['user_name']}' %>"
      password "<%= ENV['SQLADMINPWD'] || '#{poirot_node['mysql']['user_pass']}' %>"
      host poirot_node['mysql']['host']
    end
  end
end

# Set up passwords file if basic auth is configured
if node['poirot']['web']['auth']
  execute("htpasswd -bc #{node['apache']['dir']}/poirot.htpasswd #{node['poirot']['web']['auth']['user']} #{node['poirot']['web']['auth']['pass']}")
end

# Configure notifications daemon and insert default notifications
if node['poirot']['web']['notifications']
  template "poirot-notifications.conf" do
    path "/etc/init/poirot-notifications.conf"
    source "poirot-notifications.conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
      user: node['poirot']['web']['user'],
      app_dir: app_dir,
      bundle_command: "#{node[:rbenv][:root_path]}/shims/bundle"
    )
  end

  node['poirot']['web']['notifications'].each do |notification|
    mysql_database node['poirot']['mysql']['dbname'] do
      connection mysql_connection
      action :query
      sql "INSERT IGNORE INTO notifications (email, subject, query, last_run_at, created_at, updated_at) VALUES ('#{notification['email']}', '#{notification['subject']}', '#{notification['query']}', NOW(), NOW(), NOW())"
    end
  end if node['poirot']['web']['notifications'].kind_of?(Array)

  service "poirot-notifications" do
    provider Chef::Provider::Service::Upstart
    restart_command "stop poirot-notifications; start poirot-notifications"
    action :restart
  end
end

# Add poirot port to apache listen ports
unless node['apache']['listen_ports'].include?(node['poirot']['web']['port'])
  node.set['apache']['listen_ports'] = node['apache']['listen_ports'] + [node['poirot']['web']['port']]
end

# Create web app config in apache
web_app "poirot" do
  docroot "#{app_dir}/current/public"
  port node['poirot']['web']['port']
  server_name node['poirot']['web']['host']
  server_aliases []
  use_auth node['poirot']['web']['auth']
  user node['poirot']['web']['user']
  use_ssl node['poirot']['web']['ssl']
  cert_path node['poirot']['web']['cert_path']
  ca_cert_path node['poirot']['web']['ca_cert_path']
  key_path node['poirot']['web']['key_path']
end
