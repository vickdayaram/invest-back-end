class HoldingSerializer < ActiveModel::Serializer
  has_many :transactions
  attributes :id, :account_id, :name, :symbol, :shares, :current_price
end
