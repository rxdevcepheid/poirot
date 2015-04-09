name             'poirot'
maintainer       'InSTEDD'
maintainer_email 'jwajnerman@manas.com.ar'
license          'All rights reserved'
description      'Installs/Configures poirot'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "rbenv"
depends "nodejs"
depends "mysql"
depends "database"
depends "instedd-common"
