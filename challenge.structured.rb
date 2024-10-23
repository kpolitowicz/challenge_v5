#! ruby

require_relative "input_parser"
require_relative "companies_validator"
require_relative "output_formatter"

begin
  input_parser = InputParser.new
  users = input_parser.parse_json("./users.json")
  companies = input_parser.parse_json("./companies.json")

  companies_validator = CompaniesValidator.new
  if companies_validator.valid?(companies)
    # Using print to output top_up_info as-is (puts would add a new line)
    print OutputFormatter.new(companies, users).top_up_info
  else
    warn "There was a problem with companies data (inspect the JSON file):"
    companies_validator.errors.each do |key, errors|
      warn "\t#{key}:"
      errors.each { |error| warn "\t\t#{error}" }
    end
  end
rescue InputParser::Error => e
  warn "There was somthing wrong with input file"
  warn e.message
end
