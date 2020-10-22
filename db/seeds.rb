# coding: utf-8

User.create!(name: "管理者",
             employee_number: 0,
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)

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
