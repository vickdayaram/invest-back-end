class UserSerializer < ActiveModel::Serializer
  has_many :accounts, include: :all
  attributes :id, :username, :accounts
end
