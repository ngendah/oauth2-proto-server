require 'rails_helper'
require 'uri'


RSpec.describe AuthorizesController, type: :controller do

  describe '.show' do
    let(:client) { create :client }
    context 'with valid authorization code' do
      let(:redirect_url) { 'http://test.com' }
      let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: redirect_url,
               code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:params) do
        { grant_type: 'authorization_code',
          client_id: authorization.client.uid }
      end
      it {
        get :show, params: params
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(
            "#{redirect_url}?code=#{authorization.code}")
      }
    end
    context 'with valid authorization code and redirect url' do
      let(:redirect_url) { 'http://test.com' }
      let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: client.redirect_url,
               code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:params) do
        { grant_type: 'authorization_code', redirect_url: redirect_url,
          client_id: authorization.client.uid }
      end
      it {
        get :show, params: params
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(
            "#{redirect_url}?code=#{authorization.code}")
      }
    end
    context 'with valid client and redirect url' do
      let(:redirect_url) { 'http://mycomp.com' } 
      let(:params) do
        { grant_type: 'authorization_code',
          redirect_url: redirect_url,
          client_id: client.uid }
      end
      let(:parsed_url) { URI.parse(redirect_url) }
      it {
        get :show, params: params
        expect(response).to have_http_status(:found)
        expect(response.headers['Location']).to_not be_empty
        expect(
          URI.parse(response.headers['Location']).host).to eq parsed_url.host
      }
    end
  end
end
