require 'rails_helper'
require 'locale'


RSpec.describe Tokens::Type::UserCredentials, type: :oauth2 do
  include Locale

  before(:all) do
    Tokens::Type::UserCredentials.send(
      :public, *Tokens::Type::UserCredentials.protected_instance_methods)
  end
  subject(:usr_credentials) { Tokens::Type::UserCredentials.new }
  let(:redirect_url) { 'http://test.com' }
  let(:grant_type) { 'user_credentials' }

  describe '.type_name' do
    subject { usr_credentials.type_name }
    it { is_expected.to eq(grant_type) }
  end

  describe '.access_token' do
    let(:user) do
      create :user, uid: SecureRandom.uuid, password: 'password'
    end
    subject { usr_credentials.access_token(user.uid) }
    it { is_expected.to_not be_empty }
    it { is_expected.to have_key(:access_token) }
    it { is_expected.to have_key(:expires_in) }
    it (:expires_in) { is_expected.to_not eq(Time.now) }
    it (:access_token) { is_expected.to_not be_empty }
    it (:expires_in) { is_expected.to_not be_empty }
  end

  describe '.refresh_token' do
    let(:expired_token) do
      create :access_token, token: SecureRandom.uuid,
             expires: (Time.now - 10.minutes),
             refresh: true, grant_type: grant_type
    end
    let(:user) do
      create :user, uid: SecureRandom.uuid, password: 'password',
             access_tokens: [expired_token]
    end
    subject { usr_credentials.refresh_token(user.uid) }
    it { is_expected.to_not be_empty }
    it { is_expected.to have_key(:access_token) }
    it { is_expected.to have_key(:expires_in) }
    it (:expires_in) { is_expected.to_not eq(Time.now) }
    it (:access_token) { is_expected.to_not eq(expired_token[:access_token]) }
    it (:access_token) { is_expected.to_not be_empty }
    it (:expires_in) { is_expected.to_not be_empty }
  end

  describe '.token_validate' do
    context 'with invalid client id' do
      let(:params) { { client_id: 'id' } }
      let(:auth_params) { AuthParams.new(params, {}) }
      let(:errors) { [user_err(:user_credentials_invalid_client_id)] }
      subject { usr_credentials.token_validate(auth_params) }
      it { is_expected.to match_array(errors) }
    end
    context 'with valid client id and invalid username' do
      let(:user) do
        create :user, uid: SecureRandom.uuid, password: 'password'
      end
      let(:client) { create :client, users: [user] }
      let(:params) { { username: '', password: '', client_id: client.uid } }
      let(:auth_params) { AuthParams.new(params, {}) }
      let(:errors) do
        [user_err(:user_credentials_invalid_username_or_password)]
      end
      subject { usr_credentials.token_validate(auth_params) }
      it { is_expected.to match_array(errors) }
    end
    context 'with valid client id, username and invalid password' do
      let(:user) do
        create :user, uid: SecureRandom.uuid, password: 'password'
      end
      let(:client) { create :client, users: [user] }
      let(:params) do
        { username: user.uid, password: '', client_id: client.uid }
      end
      let(:auth_params) { AuthParams.new(params, {}) }
      let(:errors) do
        [user_err(:user_credentials_invalid_username_or_password)]
      end
      subject { usr_credentials.token_validate(auth_params) }
      it { is_expected.to match_array(errors) }
    end
  end

  describe '.refresh_validate' do
    context 'with invalid refresh token' do
      let(:params) do
        { refresh_token: '' }
      end
      let(:auth_params) { AuthParams.new(params, {}) }
      let(:errors) do
        [user_err(:refresh_invalid_token)]
      end
      subject { usr_credentials.refresh_validate(auth_params) }
      it { is_expected.to match_array(errors) }
    end
  end

  describe '.is_valid' do
    context 'with the action :create it validate a token request' do
      let(:params) { { client_id: 'id', action: :create.to_s } }
      let(:auth_params) { AuthParams.new(params, {}) }
      let(:errors) { [user_err(:user_credentials_invalid_client_id)] }
      subject { usr_credentials.is_valid(auth_params) }
      it { is_expected.to match_array(errors) }
    end
    context 'with the action :create it validates a refresh request' do
      let(:params) do
        { refresh_token: '', action: :update.to_s }
      end
      let(:auth_params) { AuthParams.new(params, {}) }
      let(:errors) do
        [user_err(:refresh_invalid_token)]
      end
      subject { usr_credentials.refresh_validate(auth_params) }
      it { is_expected.to match_array(errors) }
    end
    context 'with the action :destroy it validates a revoke request' do
      pending
    end
  end

  describe '.token' do
    let(:user) do
      create :user, uid: SecureRandom.uuid, password: 'password'
    end
    let(:params) { { username: user.uid, password: 'password' } }
    let(:auth_params) { AuthParams.new(params, {}) }
    context 'with a refresh token' do
      subject { usr_credentials.token(auth_params) }
      it { is_expected.to_not be_empty }
      it { is_expected.to have_key(:access_token) }
      it { is_expected.to have_key(:expires_in) }
      it { is_expected.to have_key(:refresh_token) }
      it (:expires_in) { is_expected.to_not eq(Time.now) }
      it (:access_token) { is_expected.to_not be_empty }
      it (:expires_in) { is_expected.to_not be_empty }
    end
    context 'without a refresh token' do
      subject { usr_credentials.token(auth_params, refresh_required: false) }
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
    let(:user) do
      create :user, uid: SecureRandom.uuid, password: 'password',
             access_tokens: [refresh_token]
    end
    describe 'generates a valid access token' do
      let(:params) { { refresh_token: user.access_tokens.first.token } }
      let(:auth_params) { AuthParams.new(params, {}) }
      subject { usr_credentials.refresh(auth_params) }
      it { is_expected.to_not be_empty }
      it { is_expected.to have_key(:access_token) }
      it { is_expected.to have_key(:expires_in) }
      it { is_expected.to have_key(:refresh_token) }
      it (:expires_in) { is_expected.to_not eq(Time.now) }
      it (:access_token) { is_expected.to_not be_empty }
      it (:expires_in) { is_expected.to_not be_empty }
    end
    describe 'generates a correlated access token' do
      let(:params) { { refresh_token: user.access_tokens.first.token } }
      let(:auth_params) { AuthParams.new(params, {}) }
      let(:token) { usr_credentials.refresh(auth_params) }
      subject do 
        ::AccessToken.find_by_token(token[:access_token]).correlation_uid
      end
      it { is_expected.to_not be_nil }
      it { is_expected.to eq(refresh_token.correlation_uid) }
    end
  end
end
