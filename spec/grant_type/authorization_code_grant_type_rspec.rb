require 'rails_helper'

RSpec.describe AuthorizationCodeGrantType, type: :grant_type do
  before(:all) do
    AuthorizationCodeGrantType.send(
      :public, *AuthorizationCodeGrantType.protected_instance_methods)
  end
  subject(:auth_code_grant) { AuthorizationCodeGrantType.new }
  let(:client) { create :client, user: (create :user) }
  let(:grant_type) { AuthorizationCodeGrantType.name.underscore }

  describe '.type_name' do
    subject { auth_code_grant.type_name }
    it { is_expected.to eq('authorization_code_grant_type') }
  end

  describe '.access_token' do
    let(:expired_token) do
      create :access_token, token: SecureRandom.uuid,
        expires: (Time.now - 10.minutes),
        refresh: false, grant_type: grant_type
    end
    let(:authorization) do
      create(:authorization_code, client: client,
        access_tokens: [expired_token],
        code: SecureRandom.uuid, expires: Time.now + 10.minutes)
    end
    subject { auth_code_grant.access_token(authorization.code) }
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
        access_tokens: [expired_token],
        code: SecureRandom.uuid, expires: Time.now + 10.minutes)
    end
    subject { auth_code_grant.refresh_token(authorization.code) }
    it { is_expected.to_not be_empty }
    it { is_expected.to have_key(:access_token) }
    it { is_expected.to have_key(:expires_in) }
    it (:expires_in) { is_expected.to_not eq(Time.now) }
    it (:access_token) { is_expected.to_not eq(expired_token[:access_token]) }
    it (:access_token) { is_expected.to_not be_empty }
    it (:expires_in) { is_expected.to_not be_empty }
  end

  describe '.authorize' do
    context 'with client url' do
      let(:authorization) do
        create(:authorization_code, client: client,
          code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      subject { auth_code_grant.authorize(authorization.client.uid, nil) }
      let(:result) { "#{client.redirect_url}?code=#{authorization.code}" }
      it { is_expected.to_not be_empty }
      it { is_expected.to eq(result)}
    end
    context 'with a specified url' do
      let(:redirect_url) { 'http://test.com' }
      let(:authorization) do
        create(:authorization_code, client: client,
          code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      subject { auth_code_grant.authorize(authorization.client.uid, redirect_url) }
      it { is_expected.to_not be_empty }
      it { is_expected.to eq("#{redirect_url}?code=#{authorization.code}") }
    end
  end

  describe '.validate_client' do
    context 'with valid params' do
      let(:params) { { client_id: client.uid, redirect_url: 'http://test.com' } }
      subject { auth_code_grant.validate_client(params) }
      it { is_expected.to be_empty }
    end
    context 'with invalid params' do
       let(:params) { { client_id: SecureRandom.uuid, redirect_url: nil } }
       let(:errors) { [I18n.t(:auth_code_invalid_client, scope: [:errors]),
                      I18n.t(:auth_code_redirect_url_required,
                              scope: [:errors])
                      ] }
      subject { auth_code_grant.validate_client(params) }
      it { is_expected.to_not be_empty }
      it { is_expected.to match_array(errors) }
    end
  end

  describe '.validate_code' do
    context 'with valid params and authorization' do 
      let(:authorization) do
        create(:authorization_code, client: client,
          code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:params) { { code: authorization.code } }
      let(:client_secret) { "#{client.uid}:#{client.secret}" }
      subject { auth_code_grant.validate_code(params, client_secret) }
      it { is_expected.to be_empty }
    end

    context 'with expired authorization code' do
      let(:authorization) do
        create(:authorization_code, client: client,
          code: SecureRandom.uuid, expires: Time.now - 10.minutes)
      end
      let(:params) { { code: authorization.code } }
      let(:client_secret) { "#{client.uid}:#{client.secret}" }
      let(:errors) { [I18n.t(:auth_code_expired, scope: [:errors])] }
      subject { auth_code_grant.validate_code(params, client_secret) }
      it { is_expected.to_not be_empty }
      it { is_expected.to match_array(errors) }
    end

    context 'with invalid client id or secret' do
      let(:authorization) do
        create(:authorization_code, client: client,
          code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:params) { { code: authorization.code } }
      let(:client_secret) { "#{SecureRandom.uuid}:#{client.secret}" }
      let(:errors) { [I18n.t(:auth_code_invalid_client_or_secret,
                              scope: [:errors])] }
      subject { auth_code_grant.validate_code(params, client_secret) }
      it { is_expected.to_not be_empty }
      it { is_expected.to match_array(errors) }
    end

    context 'with invalid authorization and code' do
      let(:authorization) do
        create(:authorization_code, client: client,
          code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:_) { authorization.code }
      let(:params) { { code: SecureRandom.uuid } }
      let(:client_secret) { "#{SecureRandom.uuid}#{client.secret}" }
      let(:errors) { [I18n.t(:auth_code_invalid_client_or_secret,
                              scope: [:errors]), 
                      I18n.t(:auth_code_invalid, scope: [:errors])] }
      subject { auth_code_grant.validate_code(params, client_secret) }
      it { is_expected.to_not be_empty }
      it { is_expected.to match_array(errors) }
    end
  end

  describe '.renew_token' do
    context 'with expired token refresh access token' do
      let(:access_token) do
        create(:access_token, expires: Time.now - 10.minutes, refresh: true,
               grant_type: grant_type)
      end
      let(:authorization) do
        create(:authorization_code, client: client,
          access_tokens: [access_token],
          code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      subject { auth_code_grant.renew_token access_token.token, true }
      it{ is_expected.to_not be_empty }
    end
  end
end
