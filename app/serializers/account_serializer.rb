class AccountSerializer < ActiveModel::Serializer
  attributes :id, :account_number, :account_type
end
