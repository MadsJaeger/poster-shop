# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.create!([
  {
    name: 'Admin',
    email: 'admin@posertshop.now',
    max_tokens: 1,
    token_duration: 60,
    password: 'Secure1',
    password_confirmation: 'Secure1',
    admin: true,
  },
  {
    name: 'Customer',
    email: 'custom@guy.now',
    password: 'Secure1',
    password_confirmation: 'Secure1'
  }
])