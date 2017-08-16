class HoldingSerializer < ActiveModel::Serializer
  attributes :id, :account_id, :name, :symbol, :shares, :current_price
end
