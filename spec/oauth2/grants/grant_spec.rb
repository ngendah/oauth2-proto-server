require 'rails_helper'


RSpec.describe Grants::Grant, type: :oauth2 do

  describe '.from_token' do
    context 'with valid token' do
      let(:access_token) do
        create :access_token, grant_type: 'user_credentials',
               token: SecureRandom.uuid, expires: Time.now + 1.minute
      end
      subject { Grants::Grant.from_token(access_token.token) }
      it { is_expected.to_not be_nil }
    end
    context 'with an invalid token' do
      subject { Grants::Grant.from_token(SecureRandom.uuid) }
      it { is_expected.to be_nil }
    end
  end
end