FactoryBot.define do
  factory :user do
    uid { SecureRandom.uuid }
    password { 'password' }
  end
end
