default['zabbix']['database']['install_method']     = 'mysql'
default['zabbix']['database']['dbname']             = 'zabbix'
default['zabbix']['database']['dbuser']             = 'zabbix'
default['zabbix']['database']['dbhost']             = 'localhost'
default['zabbix']['database']['dbpassword']         = nil
default['zabbix']['database']['dbport']             = '3306'
default['zabbix']['database']['allowed_user_hosts'] = 'localhost'

default['zabbix']['database']['rds_master_user']      = nil
default['zabbix']['database']['rds_master_password']  = nil

default['zabbix']['database']['mysql']['version'] = '5.5'

# SCHEMA is relevant only for IBM_DB2 database
default['zabbix']['database']['schema'] = nil
