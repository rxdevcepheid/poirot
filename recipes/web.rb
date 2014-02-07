include_recipe "rbenv_passenger"

rbenv_ruby "2.0.0-p353"
rbenv_gem "bundler" do
  ruby_version "2.0.0-p353"
end

package "nodejs"

case node['platform']
when 'ubuntu', 'debian'
  package "libsqlite3-dev"
when 'redhat', 'centos'
  package "sqlite-devel"
else
  raise "Unsupported platform: #{node['platform']}"
end

application "poirot" do
  path "/u/apps/poirot"
  repository "https://bitbucket.org/instedd/poirot.git"
  migrate true
  environment_name "production"

  rails do
    bundle_command "#{node[:rbenv][:root_path]}/shims/bundle"
    bundler true
    precompile_assets true
    symlink_logs true

    database do
      adapter :sqlite3
      database "db/production.sqlite3"
    end
  end
end

web_app "poirot" do
  docroot "/u/apps/poirot/current/public"
  server_name node['poirot']['host']
  server_aliases []
  cookbook "apache2"
end
