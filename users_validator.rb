# Proof of concept validation (no tests, no refactoring/deduplication done)
#
# A valid users param looks like this:
# [
# 	{
# 		"id": 1,
# 		"first_name": "Tanya",
# 		"last_name": "Nichols",
# 		"email": "tanya.nichols@test.com",
# 		"company_id": 2,
# 		"email_status": true,
# 		"active_status": false,
# 		"tokens": 23
# 	},
# 	...
# ]
class UsersValidator
  BASE_HEADER = "General problems"

  attr_reader :errors

  def initialize
    clear_errors
  end

  def valid?(users)
    validate_is_array?(users)
    if @errors.empty?
      users.each { |user| validate_user(user) }
    end

    @errors.empty?
  end

  private

  def clear_errors
    @errors = {}
  end

  def validate_is_array?(users)
    unless users.is_a?(Enumerable)
      push_to_error_key(BASE_HEADER, "Expected users to be a list/array.")
    end
  end

  def validate_user(user)
    validate_user_id(user)
    validate_user_company_id(user)
    validate_user_first_name(user)
    validate_user_last_name(user)
    validate_user_email(user)
    validate_user_email_status(user)
    validate_user_active_status(user)
    validate_user_tokens(user)
  end

  def validate_user_id(user)
    unless user[:id].is_a?(Integer)
      push_to_error_key(user_header(company), "Expected user Id to be an integer.")
    end
  end

  def validate_user_company_id(user)
    unless user[:company_id].is_a?(Integer)
      push_to_error_key(user_header(company), "Expected user Company Id to be an integer.")
    end
  end

  def validate_user_first_name(user)
    unless user[:first_name].is_a?(String)
      push_to_error_key(user_header(user), "Expected user First Name to be a string.")
    end
    if user[:first_name].to_s.empty?
      push_to_error_key(user_header(user), "Expected user First Name to not be blank.")
    end
  end

  def validate_user_last_name(user)
    unless user[:last_name].is_a?(String)
      push_to_error_key(user_header(user), "Expected user Last Name to be a string.")
    end
    if user[:last_name].to_s.empty?
      push_to_error_key(user_header(user), "Expected user Last Name to not be blank.")
    end
  end

  def validate_user_email(user)
    unless user[:email].is_a?(String)
      push_to_error_key(user_header(user), "Expected user Email to be a string.")
    end
    if user[:email].to_s.empty?
      push_to_error_key(user_header(user), "Expected user Email to not be blank.")
    end
    # Add RFC email format validation?
  end

  def validate_user_email_status(user)
    unless [true, false].include?(user[:email_status])
      push_to_error_key(user_header(user), "Expected user Email Status to be true/false value.")
    end
  end

  def validate_user_active_status(user)
    unless [true, false].include?(user[:active_status])
      push_to_error_key(user_header(user), "Expected user Active Status to be true/false value.")
    end
  end

  def validate_user_tokens(user)
    unless user[:tokens].is_a?(Integer)
      push_to_error_key(user_header(user), "Expected user Tokens to be an integer.")
    end
    unless user[:tokens].to_i > 0
      push_to_error_key(user_header(user), "Expected user Tokens to to be above zero.")
    end
  end

  def push_to_error_key(key, msg)
    if @errors.has_key?(key)
      @errors[key] << msg
    else
      @errors[key] = [msg]
    end
  end

  def user_header(user)
    "User: #{user[:last_name]}, #{user[:first_name]}, #{user[:email]}, Id: #{user[:id]}"
  end
end

