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
    "\n" +
      companies.map { |company| company_info(company) }.join("\n").rstrip +
    "\n"
  end

  def company_info(company)
    users_emailed, users_not_emailed = group_active_users_by_email_status(company, users[company[:id]])
    total_top_ups = (users_emailed.count + users_not_emailed.count) * company[:top_up]

    <<~COMPANY_INFO
      \tCompany Id: #{company[:id]}
      \tCompany Name: #{company[:name]}
      #{user_info("\tUsers Emailed:", company, users_emailed)}
      #{user_info("\tUsers Not Emailed:", company, users_not_emailed)}
      \t\tTotal amount of top ups for #{company[:name]}: #{total_top_ups}
    COMPANY_INFO
  end

  def group_active_users_by_email_status(company, users)
    users
      .select { |u| u[:active_status] }
      .group_by { |u| company[:email_status] && u[:email_status] }
      .values_at(true, false)
      .map { |list_or_nil| Array(list_or_nil) }
  end

  def user_info(header, company, users)
    return header if users.empty?

    "#{header}\n" +
      users.map do |u|
        <<~USER_INFO
          \t\t#{u[:last_name]}, #{u[:first_name]}, #{u[:email]}
          \t\t  Previous Token Balance, #{u[:tokens]}
          \t\t  New Token Balance #{u[:tokens] + company[:top_up]}
        USER_INFO
      end.join("\n").rstrip
  end
end
