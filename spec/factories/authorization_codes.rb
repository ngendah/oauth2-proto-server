FactoryBot.define do
  factory :authorization_code do
    code SecureRandom.uuid
    redirect_url 'https://mytest.com'
  end
end
