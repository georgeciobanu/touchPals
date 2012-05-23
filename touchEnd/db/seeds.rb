# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
users = User.create([ { email: 'george@lindenhoney.com', password: 'tatata', password_confirmation: 'tatata', partner_id: 2}, 
  {email: 'jonathan@lindenhoney.com', password: 'tatata', password_confirmation: 'tatata', partner_id: 1} ])
chats = Chat.create([ {text: 'Wow now', sender_id: 1, receiver_id: 2}, {text: 'Too fast?', sender_id: 2, receiver_id: 1}, 
  {text: 'A bit', sender_id: 1, receiver_id: 2}, {text: 'Dunno what to say about that', sender_id: 2, receiver_id: 1},
  {text: 'Well, no need to. Just kiss me!', sender_id: 1, receiver_id: 2}, {text: 'We are here', sender_id: 3, receiver_id: 4}])
