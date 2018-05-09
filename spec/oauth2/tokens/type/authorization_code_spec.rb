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

  describe '.is_valid' do
    context 'with invalid authorization code' do
      let(:params) { { authorization_code: 'code' } }
      let(:auth_params) { AuthParams.new(params, {}) }
      let(:errors) { [user_err(:auth_code_invalid)] }
      subject { auth_code_token.is_valid(auth_params) }
      it { is_expected.to match_array(errors) }
    end
    context 'with a valid authorization code but invalid headers' do
      let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: redirect_url,
               code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:auth_params) { AuthParams.new({ authorization_code: authorization.code }, {}) }
      let(:errors) { [user_err(:auth_code_invalid_client_or_secret)] }
      subject { auth_code_token.is_valid(auth_params) }
      it { is_expected.to match_array(errors) }
    end
    context 'with an expired authorization code and invalid headers' do
      let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: redirect_url,
               code: SecureRandom.uuid, expires: Time.now - 10.minutes)
      end
      let(:auth_params) { AuthParams.new({ authorization_code: authorization.code }, {}) }
      let(:errors) { [user_err(:auth_code_invalid_client_or_secret), user_err(:auth_code_expired)] }
      subject { auth_code_token.is_valid(auth_params) }
      it { is_expected.to match_array(errors) }
    end
    context 'with an invalid client id and secret' do
      let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: redirect_url,
               code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:auth_params) { AuthParams.new({ authorization_code: authorization.code }, { 'Authorization' => 'err:err' }) }
      let(:errors) { [user_err(:auth_code_invalid_client_or_secret)] }
      subject { auth_code_token.is_valid(auth_params) }
      it { is_expected.to match_array(errors) }
    end
    context 'with an invalid(can be also expired) refresh token' do
      let(:auth_params) { AuthParams.new({ refresh_token: 'token' }, {}) }
      let(:errors) { [user_err(:refresh_invalid_token)] }
      subject { auth_code_token.is_valid(auth_params) }
      it { is_expected.to match_array(errors) }
    end
  end

  describe '.token' do
    let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: redirect_url,
               code: SecureRandom.uuid, expires: Time.now + 10.minutes)
    end
    let(:params) { { authorization_code: authorization.code } }
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
             expires: (Time.now - 10.minutes),
             refresh: true, grant_type: grant_type
    end
    let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: redirect_url,
               access_tokens: [refresh_token],
               code: SecureRandom.uuid, expires: Time.now + 10.minutes)
    end
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
end