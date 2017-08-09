class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :holding_id, :buy, :sell
end
