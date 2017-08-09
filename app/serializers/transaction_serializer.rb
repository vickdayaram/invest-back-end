class TransactionSerializer < ActiveModel::Serializer
  attributes :holding_id, :buy, :sell
end
