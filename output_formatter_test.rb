require "minitest/autorun"

require_relative "output_formatter"

class OutputFormatterTest < Minitest::Test
  def setup
  end

  def test_inits_with_companies_sorted_by_id
    companies = [{
      id: 2,
      name: "Red"
    }, {
      id: 1,
      name: "Blue"
    }]
    of = OutputFormatter.new(companies, [])
    company_names = of.companies.map { |c| c[:name] }

    assert_equal ["Blue", "Red"], company_names
  end

  def test_inits_users_grouped_by_company_and_ordered_by_last_name
    users = [{
      id: 1,
      last_name: "Z",
      company_id: 2
    }, {
      id: 2,
      last_name: "A",
      company_id: 1
    }, {
      id: 1,
      last_name: "B",
      company_id: 1
    }, {
      id: 2,
      last_name: "X",
      company_id: 2
    }]
    of = OutputFormatter.new([], users)

    assert_equal [1, 2].to_set, of.users.keys.to_set # grouped by company_ids
    assert_equal ["A", "B"], of.users[1].map { |u| u[:last_name] } # ordered users in company 1
    assert_equal ["X", "Z"], of.users[2].map { |u| u[:last_name] } # ordered users in company 2
  end
end
