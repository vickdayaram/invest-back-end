class AccountSerializer < ActiveModel::Serializer
  belongs_to :user
  has_many :holdings, include: :all
  attributes :account_number, :account_type
end
