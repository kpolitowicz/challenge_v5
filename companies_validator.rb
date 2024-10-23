# Proof of concept validation (no tests, no refactoring done)
#
# A valid companies param looks like this:
# [
# 	{
# 		"id": 1,
# 		"name": "Blue Cat Inc.",
# 		"top_up": 71,
# 		"email_status": false
# 	},
# 	...
# ]
class CompaniesValidator
  BASE_HEADER = "General problems"

  attr_reader :errors

  def initialize
    clear_errors
  end

  def valid?(companies)
    validate_is_array?(companies)
    if @errors.empty?
      companies.each { |company| validate_company(company) }
    end

    @errors.empty?
  end

  private

  def clear_errors
    @errors = {}
  end

  def validate_is_array?(companies)
    unless companies.is_a?(Enumerable)
      push_to_error_key(BASE_HEADER, "Expected companies to be a list/array.")
    end
  end

  def validate_company(company)
    validate_company_id(company)
    validate_company_name(company)
    validate_company_top_up(company)
    validate_company_email_status(company)
  end

  def validate_company_id(company)
    unless company[:id].is_a?(Integer)
      push_to_error_key(company_header(company), "Expected company Id to be an integer.")
    end
  end

  def validate_company_name(company)
    unless company[:name].is_a?(String)
      push_to_error_key(company_header(company), "Expected company Name to be a string.")
    end
    if company[:name].to_s.empty?
      push_to_error_key(company_header(company), "Expected company Name to not be blank.")
    end
  end

  def validate_company_top_up(company)
    unless company[:top_up].is_a?(Integer)
      push_to_error_key(company_header(company), "Expected company Top Up to be an integer.")
    end
    unless company[:top_up].to_i > 0
      push_to_error_key(company_header(company), "Expected company Top Up to to be above zero.")
    end
  end

  def validate_company_email_status(company)
    unless [true, false].include?(company[:email_status])
      push_to_error_key(company_header(company), "Expected company Email Status to be true/false value.")
    end
  end

  def push_to_error_key(key, msg)
    if @errors.has_key?(key)
      @errors[key] << msg
    else
      @errors[key] = [msg]
    end
  end

  def company_header(company)
    "Company: #{company[:name]}, Id: #{company[:id]}"
  end
end
