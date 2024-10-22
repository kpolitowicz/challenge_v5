class OutputFormatter
  class Error < StandardError; end

  attr_reader :companies, :users

  def initialize(companies, users)
    @companies = companies.sort_by { |c| c[:id] }
    @users = users
      .sort_by { |u| u[:last_name] }
      .group_by { |u| u[:company_id] }
  end

  def top_up_info
    users
    # companies.sort_by { |c| c["id"] }.each do |company|
    #   pp company
    #   # pp group_and_sort_users(company, users[company["id"]])
    #   users_emailed, users_not_emailed = group_and_sort_users(company, users[company["id"]])
    #   pp users_emailed
    #   pp users_not_emailed
    #   # next if users_emailed.empty? && users_not_emailed.empty?

    #   # puts # the example_output.txt starts with empty line
    #   # puts "\tCompany Id: #{company["id"]}"
    #   # puts "\tCompany Name: #{company["name"]}"

    #   # puts "\tUsers Emailed:"
    #   # print_user_info(users_emailed, company)

    #   # puts "\tUsers Not Emailed:"
    #   # print_user_info(users_not_emailed, company)

    #   # puts "\t\tTotal amount of top ups for " \
    #   #   "#{company["name"]}: #{(users_emailed.count + users_not_emailed.count) * company["top_up"]}"
    # end
    # # puts # the example_output.txt ends with empty line
  end

  def group_and_sort_users(company, users)
    users
      .select { |u| u["company_id"] == company["id"] && u["active_status"] }
      .sort_by { |u| u["last_name"] }
      .group_by { |u| company["email_status"] && u["email_status"] }
      .values_at(true, false)
      .map { |list_or_nil| Array(list_or_nil) }
  end

  def print_user_info(users, company)
    users.each do |u|
      puts "\t\t#{u["last_name"]}, #{u["first_name"]}, #{u["email"]}"
      puts "\t\t  Previous Token Balance, #{u["tokens"]}"
      puts "\t\t  New Token Balance #{u["tokens"] + company["top_up"]}"
    end
  end
end
