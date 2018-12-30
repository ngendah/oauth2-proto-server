require 'rails_helper'
require 'locale'


RSpec.describe Tokens::Type::Base, type: :oauth2 do
  include Locale

  before(:all) do
    Tokens::Type::Base.send(
      :public, *Tokens::Type::Base.protected_instance_methods)
  end
  let(:base) { Tokens::Type::Base.new }

  describe '.query' do
    context 'with a valid access token' do
      let(:grant_type) { 'authorization_code' }
      let(:expires) { Time.now + 4.minutes }
      let(:access_token) do
        create :access_token, token: SecureRandom.uuid,
                              expires: expires,
                              refresh: false, grant_type: grant_type
      end
      let(:auth_params) do
        AuthParams.new({ token: access_token.token }, {})
      end
      subject(:token) { base.query(auth_params) }
      it { is_expected.to_not be_empty }
      it { is_expected.to have_key(:token_type) }
      it { is_expected.to have_key(:grant_type) }
      it { is_expected.to have_key(:expires_in) }
      it { is_expected.to have_key(:active) }
      it { is_expected.to have_key(:scope) }
      it 'is still active' do
        expect(token[:active]).to be_truthy
      end
      it 'has expires within 4 minutes' do
        time_delta = expires.tv_sec - Time.now.tv_sec
        expect(token[:expires_in]).to be_within(1).of(time_delta)
      end
    end
  end
end
