[![Build Status](https://travis-ci.org/ngendah/oauth2-proto-server.svg?branch=master)](https://travis-ci.org/ngendah/oauth2-proto-server)
[![Maintainability](https://api.codeclimate.com/v1/badges/6600fbcd63dc5bdd2809/maintainability)](https://codeclimate.com/github/ngendah/oauth2-proto-server/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/6600fbcd63dc5bdd2809/test_coverage)](https://codeclimate.com/github/ngendah/oauth2-proto-server/test_coverage)

OAuth 2 protocol server 
=======================
A modular and extensible OAuth2 server.

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
    * Build the image,
        ```
        $ docker build -t oauth-server:0.1 .
        ```
    * Run the image,
        ```
        $ docker run -p 3000:3000 oauth-server:0.1
        ```

Seed values for the development server are available [here](./db/seeds.rb)

## API Reference
* [Authorization code grant](./docs/authorization-code.md)

* [User credentials grant](./docs/user-credentials.md)

* [Implicit grant](./docs/implicit-grant.md)

* [Refresh access token](./docs/refresh-access-token.md)

* [Revoke token](./docs/revoke-token.md)

* [Token introspection](./docs/check-token.md)

## OAuth 2.0 Reference
[Framework](https://tools.ietf.org/html/rfc6749)

[Token revocation](https://tools.ietf.org/html/rfc7009)

[Token introspection](https://tools.ietf.org/html/rfc7662)

[Proof key for code exchange (PKCE)](https://tools.ietf.org/html/rfc7636)

[Security considerations](https://tools.ietf.org/html/rfc6819)
