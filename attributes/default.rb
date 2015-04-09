default['poirot']['elasticsearch']['host'] = "localhost:9200"

default['poirot']['host_name'] = node['fqdn']
default['poirot']['from_email'] = 'no-reply@poirot.instedd.org'

default['poirot']['web']['ssl']['enabled'] = false
default['poirot']['web']['ssl']['force'] = false
default['poirot']['web']['ssl']['port'] = 443
default['poirot']['web']['ssl']['cert_file'] = nil
default['poirot']['web']['ssl']['cert_key_file'] = nil
default['poirot']['web']['ssl']['cert_chain_file'] = nil

default['poirot']['web']['port'] = 80
