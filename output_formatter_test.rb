require "minitest/autorun"
require "json"

require_relative "output_formatter"

class OutputFormatterTest < Minitest::Test
  # This is an end-to-end test for to make sure the example output file is correct
  # All edge cases like email statuses and users being active are handled individually
  # by unit tests below.
  def test_matches_example_output
    users = JSON.parse(File.read("./users.json")).map { |hash| hash.transform_keys(&:to_sym) }
    companies = JSON.parse(File.read("./companies.json")).map { |hash| hash.transform_keys(&:to_sym) }
    expected_output = File.read("./example_output.txt")

    assert_equal expected_output, OutputFormatter.new(companies, users).top_up_info
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

  def test_generates_top_up_info_for_companies
    companies = [{
      id: 1,
      name: "Blue Cat Inc.",
      top_up: 71,
      email_status: true
    }, {
      id: 2,
      name: "Yellow Mouse Inc.",
      top_up: 37,
      email_status: true
    }]
    users = [{
      id: 1,
      first_name: "Tanya",
      last_name: "Nichols",
      email: "tanya.nichols@test.com",
      company_id: 2,
      email_status: true,
      active_status: true,
      tokens: 23
    }, {
      id: 9,
      first_name: "Terra",
      last_name: "Beck",
      email: "terra.beck@demo.com",
      company_id: 1,
      email_status: true,
      active_status: true,
      tokens: 41
    }]
    of = OutputFormatter.new(companies, users)

    expected = <<~TWO_COMPANIES_INFO

      \tCompany Id: 1
      \tCompany Name: Blue Cat Inc.
      \tUsers Emailed:
      \t\tBeck, Terra, terra.beck@demo.com
      \t\t  Previous Token Balance, 41
      \t\t  New Token Balance 112
      \tUsers Not Emailed:
      \t\tTotal amount of top ups for Blue Cat Inc.: 71

      \tCompany Id: 2
      \tCompany Name: Yellow Mouse Inc.
      \tUsers Emailed:
      \t\tNichols, Tanya, tanya.nichols@test.com
      \t\t  Previous Token Balance, 23
      \t\t  New Token Balance 60
      \tUsers Not Emailed:
      \t\tTotal amount of top ups for Yellow Mouse Inc.: 37

    TWO_COMPANIES_INFO

    assert_equal expected, of.top_up_info
  end

  def test_top_up_info_for_companies_skips_companies_without_users
    companies = [{
      id: 1,
      name: "Blue Cat Inc.",
      top_up: 71,
      email_status: true
    }, {
      id: 2,
      name: "Yellow Mouse Inc.",
      top_up: 37,
      email_status: true
    }]
    users = [{
      id: 1,
      first_name: "Tanya",
      last_name: "Nichols",
      email: "tanya.nichols@test.com",
      company_id: 2,
      email_status: true,
      active_status: true,
      tokens: 23
    }, {
      id: 9,
      first_name: "Terra",
      last_name: "Beck",
      email: "terra.beck@demo.com",
      company_id: 1,
      email_status: true,
      active_status: false,
      tokens: 41
    }]
    of = OutputFormatter.new(companies, users)

    expected = <<~SKIPPED_COMPANIES_INFO

      \tCompany Id: 2
      \tCompany Name: Yellow Mouse Inc.
      \tUsers Emailed:
      \t\tNichols, Tanya, tanya.nichols@test.com
      \t\t  Previous Token Balance, 23
      \t\t  New Token Balance 60
      \tUsers Not Emailed:
      \t\tTotal amount of top ups for Yellow Mouse Inc.: 37

    SKIPPED_COMPANIES_INFO

    assert_equal expected, of.top_up_info
  end

  def test_formats_single_company_info
    companies = [{
      id: 1,
      name: "Blue Cat Inc.",
      top_up: 71,
      email_status: true
    }]
    users = [{
      id: 7,
      first_name: "Amanda",
      last_name: "Pierce",
      email: "amanda.pierce@fake.com",
      company_id: 1,
      email_status: false,
      active_status: true,
      tokens: 24
    }, {
      id: 9,
      first_name: "Terra",
      last_name: "Beck",
      email: "terra.beck@demo.com",
      company_id: 1,
      email_status: true,
      active_status: true,
      tokens: 41
    }]
    of = OutputFormatter.new(companies, users)

    expected = <<~SINGLE_COMPANY_INFO
      \tCompany Id: 1
      \tCompany Name: Blue Cat Inc.
      \tUsers Emailed:
      \t\tBeck, Terra, terra.beck@demo.com
      \t\t  Previous Token Balance, 41
      \t\t  New Token Balance 112
      \tUsers Not Emailed:
      \t\tPierce, Amanda, amanda.pierce@fake.com
      \t\t  Previous Token Balance, 24
      \t\t  New Token Balance 95
      \t\tTotal amount of top ups for Blue Cat Inc.: 142
    SINGLE_COMPANY_INFO

    assert_equal expected, of.company_info(companies.first)
  end

  def test_single_company_info_nil_if_no_users
    companies = [{
      id: 1,
      name: "Blue Cat Inc."
    }]
    of = OutputFormatter.new(companies, [])

    expected = <<~SINGLE_COMPANY_INFO
      \tCompany Id: 1
      \tCompany Name: Blue Cat Inc.
      \tUsers Emailed:
      \t\tBeck, Terra, terra.beck@demo.com
      \t\t  Previous Token Balance, 41
      \t\t  New Token Balance 112
      \tUsers Not Emailed:
      \t\tPierce, Amanda, amanda.pierce@fake.com
      \t\t  Previous Token Balance, 24
      \t\t  New Token Balance 95
      \t\tTotal amount of top ups for Blue Cat Inc.: 142
    SINGLE_COMPANY_INFO

    assert_nil of.company_info(companies.first)
  end

  def test_single_company_info_nil_if_all_users_inactive
    companies = [{
      id: 1,
      name: "Blue Cat Inc.",
    }]
    users = [{
      id: 7,
      first_name: "Amanda",
      last_name: "Pierce",
      email: "amanda.pierce@fake.com",
      company_id: 1,
      email_status: false,
      active_status: false
    }, {
      id: 9,
      first_name: "Terra",
      last_name: "Beck",
      email: "terra.beck@demo.com",
      company_id: 1,
      email_status: true,
      active_status: false
    }]
    of = OutputFormatter.new(companies, users)

    assert_nil of.company_info(companies.first)
  end
end
