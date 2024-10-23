#! ruby

require_relative "input_parser"
require_relative "output_formatter"

input_parser = InputParser.new
users = input_parser.parse_json("./users.json")
companies = input_parser.parse_json("./companies.json")

# Using print to output top_up_info as-is (puts would add a new line)
print OutputFormatter.new(companies, users).top_up_info
