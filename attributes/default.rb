override['zeromq']['sha1_sum'] = '08303259f08edd1faeac2e256f5be3899377135e'
override['zeromq']['src_url'] = 'http://download.zeromq.org'
override['zeromq']['version'] = '2.2.0'

default['poirot']['receiver']['user'] = 'poirot-receiver'
default['poirot']['receiver']['port'] = 2120
default['poirot']['receiver']['internal_host'] = 'localhost'
default['poirot']['receiver']['index_prefix'] = "poirot"
default['poirot']['receiver']['debug'] = false

default['poirot']['elasticsearch']['host'] = "localhost:9200"

default['poirot']['web']['host'] = node['fqdn']
default['poirot']['web']['viewer_url'] = node['fqdn']
default['poirot']['web']['internal_host'] = node['fqdn']
default['poirot']['web']['port'] = 80
default['poirot']['web']['user'] = 'poirot-web'
default['poirot']['web']['email'] = 'no-reply@poirot.instedd.org'

default['poirot']['mysql']['user_name'] = 'poirot'
default['poirot']['mysql']['user_pass'] = ''
default['poirot']['mysql']['root_name'] = 'root'
default['poirot']['mysql']['root_pass'] = ''

default['poirot']['mysql']['host'] = 'localhost'
default['poirot']['mysql']['dbname'] = 'poirot'
