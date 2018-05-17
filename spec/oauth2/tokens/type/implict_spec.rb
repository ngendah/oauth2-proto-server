require 'rails_helper'
require 'locale'


RSpec.describe Tokens::Type::Implicit, type: :oauth2 do
  include Locale

  before(:all) do
    Tokens::Type::Implicit.send(
      :public, *Tokens::Type::Implicit.protected_instance_methods)
  end
  subject(:implicit_token) { Tokens::Type::Implicit.new }
  let(:redirect_url) { 'http://test.com' }
  let(:client) { create :client }
  let(:grant_type) { 'implicit' }

  describe '.type_name' do
    subject { implicit_token.type_name }
    it { is_expected.to eq(grant_type) }
  end

  describe '.token' do
    context 'with refresh token' do
      let(:params) do
        { client_id: client.uid, redirect_url: redirect_url, refresh: true }
      end
      let(:auth_params) { AuthParams.new(params, {}) }
      subject { implicit_token.token(auth_params) }
      it { is_expected.to_not be_empty }
      it { is_expected.to include(redirect_url) }
      it { is_expected.to include('access_token=') }
      it { is_expected.to include('expires_in=') }
      it { is_expected.to include('refresh_token=') }
    end
    context 'without a refresh token' do
      let(:params) do
        { client_id: client.uid, redirect_url: redirect_url, refresh: false }
      end
      let(:auth_params) { AuthParams.new(params, {}) }
      subject { implicit_token.token(auth_params) }
      it { is_expected.to_not be_empty }
      it { is_expected.to include(redirect_url) }
      it { is_expected.to include('access_token=') }
      it { is_expected.to include('expires_in=') }
      it { is_expected.to_not include('refresh_token=') }
    end
  end

  describe '.token_validate' do
    let(:auth_params) {AuthParams.new({}, {})}
    subject { implicit_token.token_validate(auth_params) }
    let(:errors) do
      [user_err(:auth_code_invalid_client),
       user_err(:auth_code_redirect_url_required)]
    end
    it {is_expected.to match_array(errors)}
  end
end