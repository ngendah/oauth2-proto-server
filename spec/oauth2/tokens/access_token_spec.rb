require 'rails_helper'

RSpec.describe Tokens::AccessToken, type: :oauth2 do
  let(:access_token) { Tokens::AccessToken.new }
  describe 'subscript operator' do
    context 'authorization code' do
      subject { access_token['authorization_code'] }
      it { is_expected.to_not be_nil }
    end
  end
end