require 'locale'
require 'rails_helper'


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

  describe '.generate_auth_code' do
    context 'without pkce' do
      let(:auth_params) { AuthParams.new({ client_id: client.uid }, {}) }
      subject { generate_auth_code(auth_params) }
      it { is_expected.to_not be_nil }
    end
    context 'with pkce' do
      let(:code_challenge) { "challenge" }
      let(:code_challenge_method) { "SHA256" }
      let(:client) { create :client, redirect_url: 'http://tests.com', pkce: true }
      let(:auth_params) { AuthParams.new({ client_id: client.uid,
                                           code_challenge: code_challenge,
                                           code_challenge_method: code_challenge_method },
                                         {}) }
      subject { generate_auth_code(auth_params).slice(
          :code_challenge, :code_challenge_method) }
      it { is_expected.to eq({ "code_challenge" => code_challenge,
                               "code_challenge_method" => code_challenge_method }) }
    end
  end

  describe '.validate_pkce' do
    let(:client) { create :client, redirect_url: 'http://tests.com', pkce: true }
    context 'without code challenge' do
      let(:auth_params) { AuthParams.new({ client_id: client.uid,
                                           code_challenge: nil,
                                           code_challenge_method: nil },
                                         {}) }
      let(:errors) do
        [user_err(:auth_code_challenge_required),
         user_err(:auth_code_challenge_method_required) ]
      end
      subject { validate_pkce(client, auth_params) }
      it { is_expected.to match_array(errors) }
    end
    context 'with code challenge but invalid challenge method' do
      let(:auth_params) { AuthParams.new({ client_id: client.uid,
                                           code_challenge: "challenge",
                                           code_challenge_method: "sha512" },
                                         {}) }
      let(:errors) do
        [user_err(:auth_code_invalid_grant_error)]
      end
      subject { validate_pkce(client, auth_params) }
      it { is_expected.to match_array(errors) }
    end
  end
end