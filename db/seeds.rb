if Rails.env.development?
  user_uid = '9c965d6d-ec9d-45de-9708-13f3f62d7c4d'
  client_uid = 'c2ce91a6-98b6-4d4b-99ad-eeb174c0b6d5'
  user = User.create uid: user_uid, password: 'password'
  client = Client.create uid: client_uid, secret: 'secret', redirect_url: 'https://mytest.co', users: [user]
  # register an auth code
  authorization_code = '512b9672-0a8a-11e9-9fbb-425720917a6d'
  redirect_url = 'http://localhost:3000/'
  AuthorizationCode.create client: client, code: authorization_code, redirect_url: redirect_url, expires: Time.now + 7.days
end
