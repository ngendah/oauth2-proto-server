require 'rails_helper'

RSpec.describe Tokens::AccessToken, type: :oauth2 do
  let(:access_token) { Tokens::AccessToken.new }
  describe 'subscript operator' do
    context 'with authorization code type' do
      subject { access_token['authorization_code'] }
      it { is_expected.to_not be_nil }
    end
    context 'with user credentials type' do
      subject { access_token['user_credentials'] }
      it { is_expected.to_not be_nil }
    end
    context 'with implicit type' do
      subject { access_token['implicit'] }
      it { is_expected.to_not be_nil }
    end
    context 'with introspect type' do
      subject { access_token['introspect'] }
      it { is_expected.to_not be_nil }
    end
  end
end