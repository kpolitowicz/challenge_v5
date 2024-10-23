class OutputFormatter
  attr_reader :companies, :users

  def initialize(companies, users)
    @companies = companies.sort_by { |c| c[:id] }

    # Note: grouping first then sorting to preserve the order of Bob and John Bobersons
    # However, there is no general guarantee that group_by won't affect the original
    # order anyway. The best would be to also sort by user[:id], but this was not
    # specified in the assignment.
    @users = users
      .group_by { |u| u[:company_id] }
      .transform_values { |v| v.sort_by{ |u| u[:last_name] }}
  end

  def top_up_info
    "\n" +
      companies.map { |company| company_info(company) }.compact.join("\n") +
    "\n"
  end

  def company_info(company)
    users_emailed, users_not_emailed = group_active_users_by_email_status(company, users[company[:id]])
    return nil if users_emailed.empty? && users_not_emailed.empty?

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
    Array(users)
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
      end.join.rstrip
  end
end
