# Poirot Cookbook

Cookbook for the Poirot receiver and web components, by InSTEDD.

## Attributes

### Indexing engine

Path to indexing engine where log entries are indexed

* __`poirot/elasticsearch/host`__ - Host to the elasticsearch instance to be used, note that the recipe does not install ES by itself

### Web portal

Web application settings

* __`poirot/web/host`__ - Public hostname for the web application
* __`poirot/web/port`__ - Port to access the web application, note the recipe does not install Apache by itself
* __`poirot/web/viewer_url`__ - Full url/port to the web app, such as `https://myapplication.com:3030`
* __`poirot/web/internal_host`__ - Internal IP of the server that hosts the web application
* `poirot/web/auth` - Object with `user` and `pass` attributes, if set, will be used for protecting the web app with basic auth

### Database

Relational database used for storing configuration

* `poirot/mysql/host` - Host with the MySQL database used for configuration
* `poirot/mysql/root_user` - Name of a user with privileges to set up new users and create databases
* `poirot/mysql/root_pass` - Password for the user above
* `poirot/mysql/user_pass` - Password to set for the user that will run the Poirot app

### Receiver component

Receiver service settings

* __`poirot/receiver/internal_host`__ - Internal IP of the server that hosts the receiver app
* `poirot/receiver/port` - Port to the receiver component, by default 2120

## Recipes

* __`poirot::receiver`__ - Receiver component recipe
* __`poirot::web`__ - Web portal recipe

## Validation

To validate a successful install, the following tests can be performed.

### Poirot Receiver

Check required packages are installed:

    $ yum list installed | grep zeromq
    zeromq.x86_64               2.2.0-4.el6
    zeromq-devel.x86_64         2.2.0-4.el6

Check logrotate configuration:

    $ sudo cat /etc/logrotate.d/poirot-receiver
    "/u/apps/poirot-receiver/shared/log/*.log" {
      daily
      rotate 7
      missingok
      compress
      delaycompress
      notifempty
      copytruncate
    }

Verify the receiver process is running:

    $ sudo status poirot
    > poirot start/running, process XXXX

### Poirot Web

Check connection to MySQL server as `poirot` user. Note the command will prompt for the required password, specified in the config file as `poirot/mysql/user_pass`:

    $ mysql -u poirot -P 3306 -p
    > Enter password:
    > Welcome to the MySQL monitor...

From within the previous console, issue a `SHOW databases` command and ensure the `poirot` database is listed:

    mysql> SHOW DATABASES;

    +---------------------+
    | Database            |
    +---------------------+
    | ...                 |
    | poirot              |
    | ...                 |
    +---------------------+

Check Apache is running:

    $ sudo /etc/init.d/httpd status
    > httpd (pid  XXXX) is running...

Check cepheid website definition in Apache, with the correct port and URL; note the Location node is only set if basic auth is configured:

    $ cat /etc/httpd/sites-enabled/poirot.conf
    <VirtualHost *:8090>
      ServerName myapplication.com
      DocumentRoot /u/apps/poirot-web/current/public
      CustomLog /var/log/httpd/access-poirot.log combined
      PassengerUser poirot-web

      <Location / >
        AuthType basic
        AuthName "Poirot web interface"
        AuthBasicProvider file
        AuthUserFile /etc/httpd/poirot.htpasswd
        Require valid-user
      </Location>
    </VirtualHost>

Check logrotate configuration:

    $ sudo cat /etc/logrotate.d/poirot
    "/u/apps/poirot/shared/production.log" {
      daily
      rotate 30
      create 666
      missingok
      compress
      delaycompress
      copytruncate
      notifempty
    }

Check rbenv is installed as well as the required ruby version, note that more versions could be returned:

    $ rbenv versions
    > 2.0.0-p353

Check that a request to localhost returns the appropriate status code, replacing PASSWORD by the pass defined in `poirot/web/auth/pass`:

    $ curl -u cepheid:PASSWORD -sL -w "%{http_code}\n" localhost -o /dev/null
    > 200

If there is no auth defined, replace the command above by `curl -sL -w "%{http_code}\n" localhost -o /dev/null`.

## Contributing

1. Fork the repository on Github
2. Create a named feature branch
3. Write your change
4. Submit a Pull Request using Github

