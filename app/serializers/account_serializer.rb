class AccountSerializer < ActiveModel::Serializer
  
  has_many :holdings, include: :all
  attributes :account_number, :account_type
end
