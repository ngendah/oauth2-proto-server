require 'rails_helper'

RSpec.describe 'AuthorizationCode', type: %i[controller request routing] do

  describe 'Authorization code regression' do
    context 'creates auth code, token and checks' do
      let(:client) { create :client }
      let(:redirect_url) { 'http://test.com' }
      let(:authorization) do
        create(:authorization_code, client: client,
                                    redirect_url: redirect_url,
                                    code: SecureRandom.uuid,
                                    expires: Time.now + 10.minutes)
      end
      let(:params) do
        { response_type: 'code',
          client_id: authorization.client.uid }
      end
      subject(:auth_code) {get '/authorize', params}
      it {
      }
    end
  end
end