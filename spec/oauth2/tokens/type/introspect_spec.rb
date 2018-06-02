require 'rails_helper'
require 'locale'


RSpec.describe Tokens::Type::Introspect, type: :oauth2 do
  let(:introspection) { Tokens::Type::Introspect.new }
  describe '.query' do
    describe 'authorization code grant' do
      context 'with a valid access token' do
        let(:client) { create :client }
        let(:grant_type) { 'authorization_code' }
        let(:access_token) do
          create :access_token, token: SecureRandom.uuid,
                 expires: (Time.now + 10.minutes),
                 grant_type: grant_type,
                 correlation_uid: SecureRandom.uuid
        end
        let(:authorization_code) do
          create :authorization_code, client: client,
                 expires: Time.now + 10.minutes, access_tokens: [access_token]
        end
        let(:auth_params) do
          AuthParams.new(
            {token: authorization_code.access_tokens.first.token}, {}
          )
        end
        subject { introspection.query(auth_params) }
        it { is_expected.to_not be_empty }
        it { is_expected.to have_key(:active) }
        it { is_expected.to have_key(:client_id) }
        it { expect(subject[:active]).to eq(true) }
      end
      context 'an invalid access token' do
        let(:client) {create :client}
        let(:grant_type) {'authorization_code'}
        let(:expired_access_token) do
          create :access_token, token: SecureRandom.uuid,
                 expires: (Time.now - 10.minutes),
                 grant_type: grant_type,
                 correlation_uid: SecureRandom.uuid
        end
        let(:authorization_code) do
          create :authorization_code, client: client,
                 expires: Time.now + 10.minutes,
                 access_tokens: [expired_access_token]
        end
        let(:auth_params) do
          AuthParams.new(
            { token: authorization_code.access_tokens.first.token }, {}
          )
        end
        subject { introspection.query(auth_params) }
        it { is_expected.to_not be_empty }
        it { is_expected.to have_key(:active) }
        it { is_expected.to_not have_key(:client_id) }
        it { expect(subject[:active]).to eq(false) }
      end
    end
    describe 'user credentials grant' do
      context 'with a valid access token' do
        let(:grant_type) { 'user_credentials' }
        let(:access_token) do
          create :access_token, token: SecureRandom.uuid,
                 expires: (Time.now + 10.minutes),
                 refresh: false, grant_type: grant_type
        end
        let(:user) do
          create :user, uid: SecureRandom.uuid, password: 'password',
                 access_tokens: [access_token]
        end
        let(:auth_params) do
          AuthParams.new(
            { token: user.access_tokens.first.token }, {}
          )
        end
        subject { introspection.query(auth_params) }
        it { is_expected.to_not be_empty }
        it { is_expected.to have_key(:active) }
        it { is_expected.to have_key(:user_uid) }
        it { expect(subject[:active]).to eq(true) }
      end
    end
  end
end
