FactoryBot.define do
  factory :client do
    uid { SecureRandom.uuid }
    secret { SecureRandom.uuid }
    redirect_url { 'http://mytest.com' }
  end
end
