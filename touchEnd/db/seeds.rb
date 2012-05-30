# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
users = User.create([ { email: 'george@lindenhoney.com', password: 'tatata', password_confirmation: 'tatata', partner_id: 2, username: 'Georgio', remaining_swaps: 1}, 
  {email: 'jonathan@lindenhoney.com', password: 'tatata', password_confirmation: 'tatata', partner_id: 1, username: 'Alexandra', remaining_swaps: 0} ])
chats = Chat.create([ {text: 'I just had the worst day!', sender_id: 1, receiver_id: 2}, {text: 'What happened?', sender_id: 2, receiver_id: 1},
  {text: 'Someone hit my car, busting a tail light and simply drove off before I could get the license plate down...', sender_id: 1, receiver_id: 2}, {text: 'Sounds awwwwwwful... Sorry to hear it.', sender_id: 2, receiver_id: 1},
  {text: 'Haha, I\'ll get over it. What have you been up to?!', sender_id: 1, receiver_id: 2}, {text: 'We are here', sender_id: 3, receiver_id: 4}])
