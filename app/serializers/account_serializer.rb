class AccountSerializer < ActiveModel::Serializer
  belongs_to :user
  has_many :holdings
  attributes :account_number, :account_type
end
