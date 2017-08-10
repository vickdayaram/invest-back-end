class HoldingSerializer < ActiveModel::Serializer
  has_many :transactions, include: :all
  attributes :id, :account_id, :name, :symbol, :shares, :current_price
end
