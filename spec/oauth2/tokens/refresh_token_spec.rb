require 'rails_helper'

RSpec.describe Tokens::RefreshToken, type: :oauth2 do
  let(:refresh_token) { Tokens::RefreshToken.new }
  describe 'subscript operator' do
    context 'authorization code' do
      let(:token) {
        create :access_token, token: SecureRandom.uuid,
               expires: (Time.now + 10.minutes),
               refresh: true, grant_type: :authorization_code.to_s
      }
      subject { refresh_token[token.token] }
      it { is_expected.to_not be_nil }
    end
  end
end