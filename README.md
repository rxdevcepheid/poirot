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
* __`poirot/web/viewer_url`__ - Full url/port to the web app, such as `https://remotexpert.cepheid.com:3030`
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

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Submit a Pull Request using Github

