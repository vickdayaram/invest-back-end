# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

x = User.create(username: "test", password: "test")
y = User.create(username: "test12", password: "test12")

a = Account.create(account_number: "123", account_type: "ira")
b = Account.create(account_number: "1345", account_type: "individual")

vti = Holding.create(name: "total stock", symbol: "vti")
bnd = Holding.create(name: "total bond", symbol: "bnd")

first = Transaction.create(buy: true, execution_price: "45")
first = Transaction.create(sell: true , execution_price: "100")
