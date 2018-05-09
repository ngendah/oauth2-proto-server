class Client < ApplicationRecord
  has_and_belongs_to_many :users

  def find_user_by_uid(uid)
    users.where(uid: uid).first
  end
end
