#! ruby

require_relative "input_parser"

users = InputParser.read_and_parse("./users.json")
companies = InputParser.read_and_parse("./companies.json")

