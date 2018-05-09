require 'rails_helper'

RSpec.describe Authorities::Authorize, type: :oauth2 do
  let(:authorize) { Authorities::Authorize.new }
  let(:client) { create :client, redirect_url: 'http://tests.com' }
  describe '.authorize' do
    context 'with client url' do
      let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: client.redirect_url,
               code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:auth_params) { AuthParams.new({ client_id: authorization.client.uid }, {}) }
      subject { authorize.code(auth_params, {}) }
      let(:result) { "#{client.redirect_url}?code=#{authorization.code}" }
      it { is_expected.to_not be_empty }
      it { is_expected.to eq(result) }
    end
    context 'with a specified url' do
      let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: client.redirect_url,
              code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:redirect_url) { 'http://test.com' }
      let(:auth_params) { AuthParams.new({ client_id: authorization.client.uid, redirect_url: redirect_url }, {}) }
      subject { authorize.code(auth_params, {}) }
      it { is_expected.to_not be_empty }
      it { is_expected.to eq("#{redirect_url}?code=#{authorization.code}") }
    end
  end
end