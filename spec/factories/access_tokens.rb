FactoryBot.define do
  factory :access_token do
  token SecureRandom.uuid
  refresh false
  end
end
