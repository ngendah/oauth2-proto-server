require 'rails_helper'

RSpec.describe AuthParams, type: :oauth2 do
  let(:params) do
    { code: '123', username: 'name',
      password: 'pass', refresh_token: 'token',
      client_id: 'client_id',
      redirect_url: 'http://test.com' }
  end
  let(:headers) { { "Authorization" => "client_id:secret" } }
  describe '.authorization_code' do
    subject { AuthParams.new(params, headers).authorization_code }
    it { is_expected.to eq(params[:code])}
  end
  describe '.client_id' do
    context 'with client id on the params' do
      subject { AuthParams.new(params, {}).client_id }
      it { is_expected.to eq(params[:client_id]) }
    end
    context 'with client id on the headers' do
      subject { AuthParams.new({}, headers).client_id }
      it { is_expected.to eq(params[:client_id]) }
    end
  end
  describe '.secret' do
    context 'with secret on the headers' do
      subject { AuthParams.new({}, headers).secret }
      it { is_expected.to eq('secret') }
    end
  end
  describe '.username_and_password' do
    subject { AuthParams.new(params, headers).username_password }
    it { is_expected.to match_array([params[:username], params[:password]]) }
  end
  describe '.refresh_token' do
    subject { AuthParams.new(params, headers).refresh_token }
    it { is_expected.to eq(params[:refresh_token]) }
  end
  describe '.redirect_url' do
    subject { AuthParams.new(params, headers).redirect_url }
    it { is_expected.to eq(params[:redirect_url]) }
  end
  describe '.refresh_token_key_exists' do
    subject { AuthParams.new(params, headers).refresh_token_key_exists? }
    it { is_expected.to be_truthy }
  end
end