require 'rails_helper'

RSpec.describe TokensController, type: :controller do
  describe '.show' do
    context 'with valid authorization code' do
      let(:client) {create :client}
      let(:grant_type) {'authorization_code'}
      let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: client.redirect_url,
               code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:client_secret) do
        "#{client.uid}:#{Base64.urlsafe_encode64(client.secret)}"
      end
      let(:params) do
        { code: authorization.code,
          grant_type: grant_type }
      end
      it {
        request.headers['Authorization'] = client_secret
        get :show, params: params
        expect(response).to have_http_status(:ok)
      }
    end
    context 'with grant_type implicit' do
      let(:client) { create :client }
      let(:grant_type) { 'implicit' }
      let(:redirect_url) { 'https://test.co' }
      let(:params) do
        { client_id: client.uid, redirect_url: redirect_url,
          grant_type: grant_type }
      end
      it {
        get :show, params: params
        expect(response).to have_http_status(:ok)
      }
    end
    context 'with valid user credentials' do
      let(:password) {'password'}
      let(:grant_type) {'user_credentials'}
      let(:user) do
        create :user, uid: SecureRandom.uuid, password: password
      end
      let(:client) {create :client, users: [user]}
      let(:params) do
        {username: user.uid, password: password, client_id: client.uid,
         grant_type: grant_type}
      end
      it {
        get :show, params: params
        expect(response).to have_http_status(:ok)
      }
    end
  end
  describe '.update' do
    context 'authorization code grant with valid reset token' do
      let(:client) {create :client}
      let(:grant_type) {'authorization_code'}
      let(:refresh_token) do
        create :access_token, token: SecureRandom.uuid,
               expires: (Time.now + 10.minutes),
               refresh: true, grant_type: grant_type
      end
      let(:authorization) do
        create :authorization_code, client: client,
               redirect_url: client.redirect_url,
               access_tokens: [refresh_token], code: SecureRandom.uuid,
               expires: Time.now + 10.minutes
      end
      let(:params) do
        {refresh_token: authorization.access_tokens.first.token}
      end
      it {
        put :update, params: params
        expect(response).to have_http_status(:ok)
      }
    end
    context 'user credentials with valid reset token' do
      let(:grant_type) {'user_credentials'}
      let(:refresh_token) do
        create :access_token, token: SecureRandom.uuid,
               expires: (Time.now + 10.minutes),
               refresh: true, grant_type: grant_type
      end
      let(:user) do
        create :user, password: 'password', access_tokens: [refresh_token]
      end
      let(:client) {create :client, users: [user]}
      let(:params) do
        {refresh_token: client.users.first.access_tokens.first.token,
         grant_type: grant_type}
      end
      it {
        put :update, params: params
        expect(response).to have_http_status(:ok)
      }
    end
  end
  describe '.destroy' do
    context 'with valid access token it revokes refresh token' do
      let(:grant_type) {'authorization_code'}
      let(:correlation_uid) { SecureRandom.uuid }
      let(:refresh_token) do
        create :access_token, token: SecureRandom.uuid,
               expires: (Time.now + 10.minutes),
               refresh: true, grant_type: grant_type,
               correlation_uid: correlation_uid
      end
      let(:access_token) do
        create :access_token, token: SecureRandom.uuid,
               expires: (Time.now + 10.minutes),
               refresh: false, grant_type: grant_type,
               correlation_uid: correlation_uid
      end
      let(:params) do
        { token: access_token.token }
      end
      it {
        request.headers['Authorization'] = "Bearer #{access_token.token}"
        delete :destroy, params: params
        expect(response).to have_http_status(:ok)
      }
    end
  end
end
