if Rails.env.development?
  user_uid = '9c965d6d-ec9d-45de-9708-13f3f62d7c4d'
  client_uid = 'c2ce91a6-98b6-4d4b-99ad-eeb174c0b6d5'
  user = User.create uid: user_uid, password: 'password'
  Client.create uid: client_uid, secret: 'secret', redirect_url: 'https://mytest.co', users: [user]
end
