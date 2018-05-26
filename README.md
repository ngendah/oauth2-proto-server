[![Build Status](https://travis-ci.org/ngendah/oauth2-proto-server.svg?branch=master)](https://travis-ci.org/ngendah/oauth2-proto-server)
[![Maintainability](https://api.codeclimate.com/v1/badges/6600fbcd63dc5bdd2809/maintainability)](https://codeclimate.com/github/ngendah/oauth2-proto-server/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/6600fbcd63dc5bdd2809/test_coverage)](https://codeclimate.com/github/ngendah/oauth2-proto-server/test_coverage)

OAuth 2 protocol server 
=======================
An extensible and modular OAuth2 server.

It implements the following grants:
* authorization code
* user credentials
* implicit

### Getting Started
There 2 ways:

1. With a locally installed ruby on rails
    * Clone the project.
    * Install dependencies by executing the command,
        ```
        $ bundle install
        ```
     * Setup the server,
        ```
        $ rails db:setup
        ```
     * Run the server,
        ```
        $ rails s
        ```
2. With [docker](www.docker.com)
    * Build the docker image,
        ```
        $ docker build -t oauth-server:0.1 .
        ```
    * Run the docker image,
        ```
        $ docker run -p 3000:3000 oauth-server:0.1
        ```
    Depending on your operating system, execution of docker commands may require `root` permissions or use of `sudo`.


Seed values for the development server are available [here](./db/seeds.rb)

## API Reference
* [Authorization code grant](./docs/authorization-code.md)

* [User credentials grant](./docs/user-credentials.md)

* [Implicit grant](./docs/implicit-grant.md)

* [Refresh access token](./docs/refresh-access-token.md)

* [Revoke token](./docs/revoke-token.md)

* [Check token](./docs/check-token.md)