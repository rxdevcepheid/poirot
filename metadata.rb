name             'poirot'
maintainer       'InSTEDD'
maintainer_email 'jwajnerman@manas.com.ar'
license          'All rights reserved'
description      'Installs/Configures poirot'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "build-essential"
depends "golang"
depends "zeromq"
depends "rbenv"
depends "rbenv_passenger"
depends "nodejs"
depends "application_ruby"
depends "mysql"
depends "database"
depends "logrotate"
depends "simple_iptables"
