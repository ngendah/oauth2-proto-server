require 'rails_helper'

RSpec.describe TokenController, type: :controller do
  let(:client) { create :client }
  let(:grant_type) { 'authorization_code' }
  describe '.index' do
    context 'with valid authorization code' do
      let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: client.redirect_url,
               code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:client_secret) { "#{client.uid}:#{client.secret}" }
      let(:params) do
        { authorization_code: authorization.code,
          grant_type: 'authorization_code' }
      end
      it {
        request.headers['Authorization'] = client_secret
        get :index, params: params
        expect(response).to have_http_status(:ok)
      }
    end
  end
  describe '.show' do
    context 'with valid reset token' do
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
        { refresh_token: authorization.access_tokens.first.token }
      end
      it {
        post :create, params: params
        expect(response).to have_http_status(:ok)
      }
    end
  end
end
