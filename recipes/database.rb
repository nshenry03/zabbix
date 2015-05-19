include_recipe 'zabbix::common'

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

# Generates passwords if they aren't already set
# This is INSECURE because node.normal persists the passwords to the chef
# server, making them visible to anybody with access
#
# Under chef_solo these must be set somehow because node.normal doesn't persist
# between runs

node.set_unless['zabbix']['database']['dbpassword'] = secure_password

if node['zabbix']['database']['dbhost'] == 'localhost'
  node.override['zabbix']['database']['dbhost'] = '127.0.0.1'
end

case node['zabbix']['database']['install_method']
when 'mysql', 'rds_mysql'
  mysql2_chef_gem 'default' do
    action :install
  end

  if node['zabbix']['database']['install_method'] == 'rds_mysql'
    root_username       = node['zabbix']['database']['rds_master_username']
    root_password       = node['zabbix']['database']['rds_master_password']
    allowed_user_hosts  = '%'
  elsif node['zabbix']['database']['install_method'] == 'mysql'
    node.set_unless['mysql']['server_root_password'] = secure_password
    root_username       = 'root'
    root_password       = node['mysql']['server_root_password']
    allowed_user_hosts  = node['zabbix']['database']['allowed_user_hosts']
  end

  provider = Chef::Provider::ZabbixDatabaseMySql
when 'postgres'
  node.set_unless['postgresql']['password']['postgres'] = secure_password
  root_username       = 'postgres'
  root_password       = node['postgresql']['password']['postgres']
  provider = Chef::Provider::ZabbixDatabasePostgres
when 'oracle'
  # No oracle database installation or configuration currently done
  # This recipe expects a fully configured Oracle DB with a Zabbix
  # user + schema. The instant client is just for compiling php-oci8
  # and Zabbix itself
  include_recipe 'oracle-instantclient'
  include_recipe 'oracle-instantclient::sdk'
  # Not used yet but needs to be set
  root_username       = 'sysdba'
  root_password       = 'not_applicable'
  provider = Chef::Provider::ZabbixDatabaseOracle
end

zabbix_database node['zabbix']['database']['dbname'] do
  provider provider
  host node['zabbix']['database']['dbhost']
  port node['zabbix']['database']['dbport'].to_i
  username node['zabbix']['database']['dbuser']
  password node['zabbix']['database']['dbpassword']
  root_username root_username
  root_password root_password
  allowed_user_hosts allowed_user_hosts
  source_url node['zabbix']['server']['source_url']
  server_version node['zabbix']['server']['version']
  source_dir node['zabbix']['src_dir']
  install_dir node['zabbix']['install_dir']
  branch node['zabbix']['server']['branch']
  version node['zabbix']['server']['version']
end
