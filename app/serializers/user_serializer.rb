class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :accounts
end
