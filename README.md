[![Build Status](https://travis-ci.org/ngendah/oauth2-proto-server.svg?branch=master)](https://travis-ci.org/ngendah/oauth2-proto-server)
[![Maintainability](https://api.codeclimate.com/v1/badges/6600fbcd63dc5bdd2809/maintainability)](https://codeclimate.com/github/ngendah/oauth2-proto-server/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/6600fbcd63dc5bdd2809/test_coverage)](https://codeclimate.com/github/ngendah/oauth2-proto-server/test_coverage)

OAuth 2 protocol server 
=======================
implements the following grants:
* authorization code
* user credentials
* implicit

grants in progress:
* client credentials

### install dependencies
``
$ bundle install
``

### Tests
```
$ RAILS_ENV=test rails db:setup
$ rspec
```

## Running development server

using installed rails;
```
$ rails db:setup
$ rails s
```
for seed values, see `db/seeds.rb`

using docker;

```
$ docker build -t oauth-server:0.1 .
$ docker run -p 3000:3000 oauth-server:0.1
```

### Authorization code
* code generation:
```
curl -i http://localhost:3000/authorize?grant_type=authorization_code&client_id=c2ce91a6-98b6-4d4b-99ad-eeb174c0b6d5&redirect_url=https%3A%2F%2Ftest.com
```

example result:
```
HTTP/1.1 307 Temporary Redirect
Location: https://test.com?code=G_Ds4r17gd23134OniYYiA
Content-Type: application/json; charset=utf-8
```

* token generation:

set the param `code` with the code received

```
curl -i -H "Authorization: c2ce91a6-98b6-4d4b-99ad-eeb174c0b6d5:c2VjcmV0" http://localhost:3000/token?grant_type=authorization_code&code=
```

if a refresh token is required,

```
curl -i -H "Authorization: c2ce91a6-98b6-4d4b-99ad-eeb174c0b6d5:c2VjcmV0" http://localhost:3000/token?grant_type=authorization_code&refresh=true&code=
```

### User credentials
```
curl -i http://localhost:3000/token?grant_type=user_credentials&client_id=c2ce91a6-98b6-4d4b-99ad-eeb174c0b6d5&username=9c965d6d-ec9d-45de-9708-13f3f62d7c4d&password=password
```
if a refresh token is required, add the param `refresh=true`

### implicit
```
curl -i http://localhost:3000/token?grant_type=implicit&client_id=c2ce91a6-98b6-4d4b-99ad-eeb174c0b6d5&redirect_url=https%3A%2F%2Ftest.com
```

if a refresh token is required, add the param `refresh=true`

### Refresh token
```
curl -i -X 'PUT' http://localhost:3000/token?refresh=true&refresh_token=
```

### Revoke token
```
curl -i -X 'DELETE' -H "Authorization: Bearer access_token" http://localhost:3000/token?token=
```