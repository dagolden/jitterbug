#
# Cookbook Name:: jitterbug
# Recipe:: default
#
# Copyright 2012, David Golden
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'carton'
include_recipe 'perlbrew'
include_recipe 'nginx'

package 'git-core'
package 'libxml2-dev'
package 'libexpat-dev'
package 'zlib1g-dev'

user node['jitterbug']['user'] do
  home '/home/jitterbug'
end

git node['jitterbug']['deploy_dir'] do
  repository node['jitterbug']['deploy_repo']
  reference node['jitterbug']['deploy_tag']
  notifies :restart, "carton_app[jitterbug]"
end

template "#{node[:nginx][:dir]}/sites-available/jitterbug.conf" do
  source "jitterbug.conf.erb"
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :host_name => node[:fqdn]
  )

  if File.exists?("#{node[:nginx][:dir]}/sites-enabled/jitterbug.conf")
    notifies :restart, 'service[nginx]'
  end
end

directory node['jitterbug']['conf_dir'] do
  owner node['jitterbug']['user']
  group node['jitterbug']['group']
end

template "#{node['jitterbug']['conf_dir']}/config.yml" do
  source "config.yml.erb"
  owner node['jitterbug']['user']
  group node['jitterbug']['group']
  mode '0644'
  notifies :restart, "carton_app[jitterbug]", :delayed
end

directory node['jitterbug']['db_dir'] do
  owner node['jitterbug']['user']
  group node['jitterbug']['group']
end

cookbook_file "#{node['jitterbug']['db_dir']}/jitterbug.db" do
  source "jitterbug.db"
  mode "0644"
  owner node['jitterbug']['user']
  group node['jitterbug']['group']
  action :create_if_missing
end

file "#{node['jitterbug']['db_dir']}/jitterbug.db" do
  mode "0644"
  owner node['jitterbug']['user']
  group node['jitterbug']['group']
  action :touch
end

carton_app "jitterbug" do
  perlbrew node['jitterbug']['perl_version']
  command "#{node['jitterbug']['deploy_dir']}/jitterbug.pl -p #{node['jitterbug']['port']} -c #{node['jitterbug']['conf_dir']}/config.yml"
  cwd node['jitterbug']['deploy_dir']
  user node['jitterbug']['user']
  group node['jitterbug']['group']
  action [:enable, :start]
end

carton_app "jitterbug-builder" do
  perlbrew node['jitterbug']['perl_version']
  command "perl #{node['jitterbug']['deploy_dir']}/scripts/builder.pl -c #{node['jitterbug']['conf_dir']}/config.yml"
  cwd node['jitterbug']['deploy_dir']
  user node['jitterbug']['user']
  group node['jitterbug']['group']
  action [:enable, :start]
end

nginx_site "jitterbug.conf" do
    enable true
    notifies :reload, 'service[nginx]'
end
