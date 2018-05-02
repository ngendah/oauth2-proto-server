require 'rails_helper'

RSpec.describe AuthorizationCodeGrantType, type: :grant_type do
  before(:all) do
    AuthorizationCodeGrantType.send(
      :public, *AuthorizationCodeGrantType.protected_instance_methods)
  end

  subject(:auth_code_grant) { AuthorizationCodeGrantType.new }
  let(:client) { create :client, user: (create :user) }

  context :type_name do
    subject { auth_code_grant.type_name }
    it { is_expected.to eq('authorization_code_grant_type') }
  end

  context :access_token do
    let(:expired_token) do
      create :access_token, token: SecureRandom.uuid,
        expires: (Time.now - 10.minutes),
        refresh: false
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

  context :refresh_token do
    let(:expired_token) do
      create :access_token, token: SecureRandom.uuid,
        expires: (Time.now - 10.minutes),
        refresh: true
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

  context :authorize do 
    describe 'with client url' do
      let(:authorization) do
        create(:authorization_code, client: client,
          code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      subject { auth_code_grant.authorize(authorization.client.uid, nil) }
      let(:result) { "#{client.redirect_url}?code=#{authorization.code}" }
      it { is_expected.to_not be_empty }
      it { is_expected.to eq(result)}
    end
    describe 'with a specified url' do
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
end
