require 'rails_helper'
require 'locale'


RSpec.describe Lib::AuthorizationCode, type: :oauth2 do
  include Locale
  include Lib::AuthorizationCode

  let(:client) { create :client, redirect_url: 'http://tests.com' }
  describe '.authorize' do
    context 'with client url' do
      let(:authorization) do
        create(:authorization_code, client: client,
               redirect_url: client.redirect_url,
               code: SecureRandom.uuid, expires: Time.now + 10.minutes)
      end
      let(:auth_params) { AuthParams.new({ client_id: authorization.client.uid }, {}) }
      subject { generate_code(auth_params) }
      let(:result) do
        { redirect_url: client.redirect_url, code: authorization.code }
      end
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
      let(:result) do
        { redirect_url: redirect_url, code: authorization.code }
      end
      subject { generate_code(auth_params) }
      it { is_expected.to_not be_empty }
      it { is_expected.to eq(result) }
    end
  end

  describe '.is_valid' do
    let(:auth_params) { AuthParams.new({}, {}) }
    subject { validate_client(auth_params) }
    let(:errors) do
      [user_err(:auth_code_invalid_client),
       user_err(:auth_code_redirect_url_required)]
    end
    it { is_expected.to match_array(errors) }
  end
end