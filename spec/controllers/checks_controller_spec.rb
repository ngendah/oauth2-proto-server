require 'rails_helper'

RSpec.describe ChecksController, type: :controller do
  let(:grant_type) { 'user_credentials' }
  describe 'show' do
    context 'with a valid token' do
      let(:access_token) do
        create :access_token, token: SecureRandom.uuid,
               expires: (Time.now + 10.minutes),
               refresh: false, grant_type: grant_type
      end
      it {
        get :show, params: { token: access_token.token }
        expect(response).to have_http_status(:found)
      }
    end
    context 'with an invalid token' do
      it {
        get :show, params: { token: SecureRandom.uuid }
        expect(response).to have_http_status(:not_found)
      }
    end
  end
end