# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
u= User.new(first_name: "Admin", last_name: "User", email: 'admin@npte.com', password: "admin333", password_confirmation: 'admin333', phone: '23234344344', role: 'admin')
u.save(validate: false)