[![Build Status](https://travis-ci.org/ngendah/oauth2-proto-server.svg?branch=master)](https://travis-ci.org/ngendah/oauth2-proto-server)
[![Maintainability](https://api.codeclimate.com/v1/badges/6600fbcd63dc5bdd2809/maintainability)](https://codeclimate.com/github/ngendah/oauth2-proto-server/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/6600fbcd63dc5bdd2809/test_coverage)](https://codeclimate.com/github/ngendah/oauth2-proto-server/test_coverage)
[![security](https://hakiri.io/github/ngendah/oauth2-proto-server/master.svg)](https://hakiri.io/github/ngendah/oauth2-proto-server/master)

OAuth 2 protocol server 
=======================
A modular and extensible OAuth2 server.

It implements the following grants:
* authorization code with PKCE
* user credentials
* implicit

### Getting Started
OAuth2 server uses [OpenApi](https://www.openapis.org/) standard to generate its documentation and make it easier to get started.
The only dependency required is [docker-compose](https://docs.docker.com/compose/).

1. Clone the project.

2. Change your current directory
    ```
    $ cd  docker-compose
    ```

2. Build and run the app,
   ```
    $ docker-compose -f development.yml up
   ```
3. On your browser navigate to `localhost:8080`.
![Alt Text](./docs/pics/oauth2-server.png)
4. Reference documents are available at `docs/auth-code`, `docs/user-cred` and `docs/implicit`.

Seed values for the development server are available [here](./db/seeds.rb)

The server is still in active development and is some few steps away from being completely ready for production.
However, a minimal production deployment is available in the directory `docker-compose`.

## OAuth 2.0 Reference
[Framework](https://tools.ietf.org/html/rfc6749)

[Token revocation](https://tools.ietf.org/html/rfc7009)

[Token introspection](https://tools.ietf.org/html/rfc7662)

[Proof key for code exchange (PKCE)](https://tools.ietf.org/html/rfc7636)

[Security considerations](https://tools.ietf.org/html/rfc6819)
