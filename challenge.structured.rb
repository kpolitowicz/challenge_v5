#! ruby

require_relative "input_parser"

InputParser.read_and_parse("./user.json")
users = InputParser.read_and_parse("./users.json")
InputParser.read_and_parse("./companies.json")

puts users
