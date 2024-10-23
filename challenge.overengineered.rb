#! ruby

require_relative "input_parser"
require_relative "companies_validator"
require_relative "users_validator"
require_relative "output_formatter"

def report_errors(companies_validator, users_validator)
  unless companies_validator.errors.empty?
    warn "There was a problem with companies data (inspect the JSON file):"
    companies_validator.errors.each do |key, errors|
      warn "\t#{key}:"
      errors.each { |error| warn "\t\t#{error}" }
    end
  end

  unless users_validator.errors.empty?
    warn "There was a problem with users data (inspect the JSON file):"
    users_validator.errors.each do |key, errors|
      warn "\t#{key}:"
      errors.each { |error| warn "\t\t#{error}" }
    end
  end
end

begin
  input_parser = InputParser.new
  users = input_parser.parse_json("./users.json")
  companies = input_parser.parse_json("./companies.json")

  # Validation is proof-of-concept - there is some cleanup pending once
  # the requirements are clarified.
  companies_validator = CompaniesValidator.new
  users_validator = UsersValidator.new
  companies_valid = companies_validator.valid?(companies)
  users_valid = users_validator.valid?(users)
  if companies_valid && users_valid
    # Using print to output top_up_info as-is (puts would add a new line)
    print OutputFormatter.new(companies, users).top_up_info
  else
    report_errors(companies_validator, users_validator)
  end
rescue InputParser::Error => e
  warn "There was somthing wrong with input file"
  warn e.message
end
