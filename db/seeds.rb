# coding: utf-8

User.create!(name: "管理者",
             employee_number: 0,
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)

User.create!(name: "上長A",
             employee_number: 1,
             email: "superior-1@email.com",
             password: "password",
             password_confirmation: "password",
             superior: true)
             
User.create!(name: "上長B",
             employee_number: 2,
             email: "superior-2@email.com",
             password: "password",
             password_confirmation: "password",
             superior: true)

3.times do |n|
  name = Faker::Name.name
  employee_number = n+1
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               employee_number: employee_number,
               email: email,
               password: password,
               password_confirmation: password)
end
