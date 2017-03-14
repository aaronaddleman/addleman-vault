src_filename = "vault.zip"
src_filepath = "#{Chef::Config['file_cache_path']}/#{src_filename}"
extract_path = "#{
  Chef::Config['file_cache_path']
  }/vault/#{
  node['vault']['client']['checksum']
}"

remote_file src_filepath do
  source node['vault']['client']['url']
  checksum node['vault']['client']['checksum']
end

package 'unzip'

execute 'unzip_vault' do
  command "unzip #{src_filepath} -d #{node['vault']['client']['pathdir']}"
  subscribes :run, 'package["unzip"]'
  subscribes :run, 'remote_file["src_filepath"]'
  not_if { ::File.exist?("#{node['vault']['client']['pathdir']}/vault")}
end

user 'vault' do
  comment 'Vault agent'
  home '/home/vault'
end

directory '/etc/vault/' do
  owner 'root'
  group 'root'
  mode '0755'
end

directory '/etc/vault.d/agent' do
  owner 'vault'
  group 'vault'
  mode '0755'
  recursive true
end
template '/etc/vault.d/agent/config.hcl' do
  source 'vault-config.hcl.erb'
  owner 'vault'
  group 'vault'
  mode '0644'
  variables certpath: node['selfsigned_certificate']['destination']
  notifies :restart, 'systemd_unit[vault.service]', :delayed
end

template '/etc/systemd/system/vault.service' do
  source 'vault.service.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :aws_access_key => node['aws_access_key'],
    :aws_secret_key => node['aws_secret_key']
  )
end

systemd_unit 'vault.service' do
  enabled true
  action [:enable, :start]
end
