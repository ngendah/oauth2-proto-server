require 'rails_helper'
require 'locale'


RSpec.describe Tokens::Type::AuthorizationCode, type: :oauth2 do
  include Locale

  before(:all) do
    Tokens::Type::AuthorizationCode.send(
      :public, *Tokens::Type::AuthorizationCode.protected_instance_methods)
  end
  subject(:auth_code_token) { Tokens::Type::AuthorizationCode.new }
  let(:redirect_url) { 'http://test.com' }
  let(:client) { create :client }
  let(:grant_type) { 'authorization_code' }

  describe '.type_name' do
    subject { auth_code_token.type_name }
    it { is_expected.to eq(grant_type) }
  end

  describe '.access_token' do
    let(:expired_token) do
      create :access_token, token: SecureRandom.uuid,
             expires: (Time.now - 10.minutes),
             refresh: false, grant_type: grant_type
    end
    let(:authorization) do
      create(:authorization_code, client: client,
             redirect_url: redirect_url,
             access_tokens: [expired_token],
             code: SecureRandom.uuid, expires: Time.now + 10.minutes)
    end
    subject { auth_code_token.access_token(authorization.code) }
    it { is_expected.to_not be_empty }
    it { is_expected.to have_key(:access_token) }
    it { is_expected.to have_key(:expires_in) }
    it (:expires_in) { is_expected.to_not eq(Time.now) }
    it (:access_token) { is_expected.to_not eq(expired_token[:access_token]) }
    it (:access_token) { is_expected.to_not be_empty }
    it (:expires_in) { is_expected.to_not be_empty }
  end

  describe '.refresh_token' do
    let(:expired_token) do
      create :access_token, token: SecureRandom.uuid,
             expires: (Time.now - 10.minutes),
             refresh: true, grant_type: grant_type
    end
    let(:authorization) do
      create(:authorization_code, client: client,
             redirect_url: redirect_url,
             access_tokens: [expired_token],
             code: SecureRandom.uuid, expires: Time.now + 10.minutes)
    end
    subject { auth_code_token.refresh_token(authorization.code) }
    it { is_expected.to_not be_empty }
    it { is_expected.to have_key(:access_token) }
    it { is_expected.to have_key(:expires_in) }
    it (:expires_in) { is_expected.to_not eq(Time.now) }
    it (:access_token) { is_expected.to_not eq(expired_token[:access_token]) }
    it (:access_token) { is_expected.to_not be_empty }
    it (:expires_in) { is_expected.to_not be_empty }
  end

  describe '.refresh_validate' do
    let(:auth_params) { AuthParams.new({ refresh_token: 'token' }, {}) }
    let(:errors) { [user_err(:refresh_invalid_token)] }
    subject { auth_code_token.refresh_validate(auth_params) }
    it { is_expected.to match_array(errors) }
  end

  describe '.create_validate' do
    context 'with invalid authorization code' do
      let(:params) { { code: 'code' } }
      let(:auth_params) { AuthParams.new(params, {}) }
      let(:errors) { [user_err(:auth_code_invalid)] }
      subject { auth_code_token.token_validate(auth_params) }
      it { is_expected.to match_array(errors) }
    end
    context 'with a valid authorization code but invalid headers' do
      let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: redirect_url,
               code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:auth_params) { AuthParams.new({ code: authorization.code }, {}) }
      let(:errors) { [user_err(:auth_code_invalid_client_or_secret)] }
      subject { auth_code_token.token_validate(auth_params) }
      it { is_expected.to match_array(errors) }
    end
    context 'with an expired authorization code and invalid headers' do
      let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: redirect_url,
               code: SecureRandom.uuid, expires: Time.now - 10.minutes)
      end
      let(:auth_params) { AuthParams.new({ code: authorization.code }, {}) }
      let(:errors) { [user_err(:auth_code_invalid_client_or_secret), user_err(:auth_code_expired)] }
      subject { auth_code_token.token_validate(auth_params) }
      it { is_expected.to match_array(errors) }
    end
    context 'with an invalid client id and secret' do
      let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: redirect_url,
               code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:auth_params) do
        AuthParams.new(
          { code: authorization.code },
          'Authorization' => 'err:err'
        )
      end
      let(:errors) { [user_err(:auth_code_invalid_client_or_secret)] }
      subject { auth_code_token.token_validate(auth_params) }
      it { is_expected.to match_array(errors) }
    end
  end

  describe '.is_valid' do
    context 'with the action :index it validates an access token request' do
      let(:params) { { code: 'code', action: :index.to_s } }
      let(:auth_params) { AuthParams.new(params, {}) }
      let(:errors) { [user_err(:auth_code_invalid)] }
      subject { auth_code_token.token_validate(auth_params) }
      it { is_expected.to match_array(errors) }
    end
    context 'with the action :create it validates a refresh request' do
      let(:auth_params) do
        AuthParams.new({ refresh_token: 'token', action: :create.to_s }, {})
      end
      let(:errors) { [user_err(:refresh_invalid_token)] }
      subject { auth_code_token.refresh_validate(auth_params) }
      it { is_expected.to match_array(errors) }
    end
    context 'with the action :destroy it validates a revoke request' do
      pending
    end
    context 'with an invalid action it raises an exception' do
      let(:auth_params) do
        AuthParams.new({ refresh_token: 'token' }, {})
      end
      subject { auth_code_token.refresh_validate(auth_params) }
    end
  end

  describe '.token' do
    let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: redirect_url,
               code: SecureRandom.uuid, expires: Time.now + 10.minutes)
    end
    let(:params) { { code: authorization.code } }
    let(:auth_params) { AuthParams.new(params, {}) }
    context 'with a required refresh token' do
      subject { auth_code_token.token(auth_params) }
      it { is_expected.to_not be_empty }
      it { is_expected.to have_key(:access_token) }
      it { is_expected.to have_key(:expires_in) }
      it { is_expected.to have_key(:refresh_token) }
      it (:expires_in) { is_expected.to_not eq(Time.now) }
      it (:access_token) { is_expected.to_not be_empty }
      it (:expires_in) { is_expected.to_not be_empty }
    end
    context 'with a correlated refresh token' do
      let(:token) { auth_code_token.token(auth_params) }
      let(:correlation_uid) do
        ::AccessToken.find_by_token(token[:access_token]).correlation_uid
      end
      subject do
        ::AccessToken.find_by_token(token[:refresh_token]).correlation_uid
      end
      it { is_expected.to eq(correlation_uid) }
    end
    context 'without a refresh token' do
      subject { auth_code_token.token(auth_params, refresh_required: false) }
      it { is_expected.to_not be_empty }
      it { is_expected.to have_key(:access_token) }
      it { is_expected.to have_key(:expires_in) }
      it { is_expected.to_not have_key(:refresh_token) }
      it (:expires_in) { is_expected.to_not eq(Time.now) }
      it (:access_token) { is_expected.to_not be_empty }
      it (:expires_in) { is_expected.to_not be_empty }
    end
  end
  describe '.refresh' do
    let(:refresh_token) do
      create :access_token, token: SecureRandom.uuid,
             expires: (Time.now + 10.minutes),
             refresh: true, grant_type: grant_type,
             correlation_uid: SecureRandom.uuid
    end
    let(:authorization) do
      create(:authorization_code, client: client,
             redirect_url: redirect_url,
             access_tokens: [refresh_token],
             code: SecureRandom.uuid, expires: Time.now + 10.minutes)
    end
    describe 'generate a valid access token' do
      let(:params) { { refresh_token: authorization.access_tokens.first.token } }
      let(:auth_params) { AuthParams.new(params, {}) }
      subject { auth_code_token.refresh(auth_params) }
      it { is_expected.to_not be_empty }
      it { is_expected.to have_key(:access_token) }
      it { is_expected.to have_key(:expires_in) }
      it { is_expected.to have_key(:refresh_token) }
      it (:expires_in) { is_expected.to_not eq(Time.now) }
      it (:access_token) { is_expected.to_not be_empty }
      it (:expires_in) { is_expected.to_not be_empty }
    end
    describe 'generates a correlated access token' do
      let(:params) do
        { refresh_token: authorization.access_tokens.first.token }
      end
      let(:auth_params) { AuthParams.new(params, {}) }
      let(:token) { auth_code_token.refresh(auth_params) }
      subject do 
        ::AccessToken.find_by_token(token[:access_token]).correlation_uid
      end
      it { is_expected.to_not be_nil }
      it { is_expected.to eq(refresh_token.correlation_uid) }
    end
  end
  describe '.revoke_validate' do
    context 'with an invalid authentication header' do
      let(:params) do
        { token: '' }
      end
      let(:auth_params) { AuthParams.new(params, {}) }
      subject { auth_code_token.revoke_validate(auth_params) }
      let(:errors) { [user_err(:bad_auth_header)] }
      it { is_expected.to match_array(errors) }
    end
    context 'with an invalid token' do
      let(:access_token) do
      create :access_token, token: SecureRandom.uuid,
             expires: (Time.now + 10.minutes),
             grant_type: grant_type,
             correlation_uid: SecureRandom.uuid
      end
      let(:params) do
        { token: '' }
      end
      let(:auth_params) do
        AuthParams.new(
          params,
          'Authorization' => "Bearer #{access_token.token}"
        )
      end
      subject { auth_code_token.revoke_validate(auth_params) }
      let(:errors) { [user_err(:token_invalid)] }
      it { is_expected.to match_array(errors) }
    end
  end
end
