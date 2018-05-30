require 'rails_helper'

RSpec.describe ChecksController, type: :controller do
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
  describe 'show' do
    context 'with a valid token' do
      it {
        request.headers['Authorization'] = "Bearer #{user.access_tokens.first.token}"
        get :show, params: { token: access_token.token }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key(:active.to_s)
      }
    end
    context 'with an invalid token' do
      it {
        request.headers['Authorization'] = "Bearer #{access_token.token}"
        get :show, params: { token: SecureRandom.uuid }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key(:active.to_s)
      }
    end
  end
end