#! ruby

require "json"

users = JSON.parse(File.read("./users.json"))
companies = JSON.parse(File.read("./companies.json"))

puts companies
