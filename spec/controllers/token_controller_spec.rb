require 'rails_helper'

RSpec.describe TokenController, type: :controller do

  describe '.index' do
    let(:client) { create :client, user: (create :user) } 
    context 'with valid authorization code' do
      let(:authorization) do
          create(:authorization_code, client: client,
            code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:client_secret) { "#{client.uid}:#{client.secret}" }
      let(:params) { { code: authorization.code,
                      grant_type: 'authorization_code' } }
      it {
        request.headers['Authorization'] = client_secret
        get :index, params: params
        expect(response).to have_http_status(:ok) 
      }
    end
  end
end
