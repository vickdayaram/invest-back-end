class UserSerializer < ActiveModel::Serializer
  has_many :accounts
  attributes :id, :username, :accounts
end
