require "minitest/autorun"

require_relative "output_formatter"
require_relative "input_parser"

class OutputFormatterTest < Minitest::Test
  # This is an end-to-end test for to make sure the example output file is correct
  # All edge cases like email statuses and users being active are handled individually
  # by unit tests below.
  def test_matches_example_output
    input_parser = InputParser.new
    users = input_parser.parse_json("./users.json")
    companies = input_parser.parse_json("./companies.json")

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
    company = {
      id: 1,
      name: "Blue Cat Inc.",
      top_up: 71,
      email_status: true
    }
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
    of = OutputFormatter.new([company], users)

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

    assert_equal expected, of.company_info(company)
  end

  def test_single_company_info_nil_if_no_users
    company = {
      id: 1,
      name: "Blue Cat Inc."
    }
    of = OutputFormatter.new([company], [])

    assert_nil of.company_info(company)
  end

  def test_single_company_info_nil_if_all_users_inactive
    company = {
      id: 1,
      name: "Blue Cat Inc.",
    }
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
    of = OutputFormatter.new([company], users)

    assert_nil of.company_info(company)
  end

  def test_groups_users_by_email_status
    company = {
      id: 1,
      name: "Blue Cat Inc.",
      email_status: true
    }
    users = [{
      id: 7,
      first_name: "Amanda",
      last_name: "Pierce",
      email: "amanda.pierce@fake.com",
      company_id: 1,
      email_status: false,
      active_status: true
    }, {
      id: 9,
      first_name: "Terra",
      last_name: "Beck",
      email: "terra.beck@demo.com",
      company_id: 1,
      email_status: true,
      active_status: true
    }]
    of = OutputFormatter.new([company], users)

    users_emailed, users_not_emailed = of.group_active_users_by_email_status(company, users)

    assert_equal ["Terra"], users_emailed.map { |u| u[:first_name] }
    assert_equal ["Amanda"], users_not_emailed.map { |u| u[:first_name] }
  end

  def test_groups_active_users_only
    company = {
      id: 1,
      name: "Blue Cat Inc.",
      email_status: true
    }
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
      active_status: true
    }]
    of = OutputFormatter.new([company], users)

    users_emailed, users_not_emailed = of.group_active_users_by_email_status(company, users)

    assert_equal ["Terra"], users_emailed.map { |u| u[:first_name] }
    assert_equal [], users_not_emailed.map { |u| u[:first_name] }
  end

  def test_puts_users_on_not_emailed_if_company_email_status_false
    company = {
      id: 1,
      name: "Blue Cat Inc.",
      email_status: false
    }
    users = [{
      id: 7,
      first_name: "Amanda",
      last_name: "Pierce",
      email: "amanda.pierce@fake.com",
      company_id: 1,
      email_status: false,
      active_status: true
    }, {
      id: 9,
      first_name: "Terra",
      last_name: "Beck",
      email: "terra.beck@demo.com",
      company_id: 1,
      email_status: true,
      active_status: true
    }]
    of = OutputFormatter.new([company], users)

    users_emailed, users_not_emailed = of.group_active_users_by_email_status(company, users)

    assert_equal [], users_emailed.map { |u| u[:first_name] }
    assert_equal ["Amanda", "Terra"], users_not_emailed.map { |u| u[:first_name] }
  end

  def test_generates_users_info_with_header
    company = {
      id: 1,
      name: "Blue Cat Inc.",
      top_up: 71,
    }
    users = [{
      id: 7,
      first_name: "Amanda",
      last_name: "Pierce",
      email: "amanda.pierce@fake.com",
      company_id: 1,
      tokens: 24
    }, {
      id: 9,
      first_name: "Terra",
      last_name: "Beck",
      email: "terra.beck@demo.com",
      company_id: 1,
      tokens: 41
    }]
    of = OutputFormatter.new([company], users)

    expected = <<~USERS_INFO
      \tCustom Header:
      \t\tPierce, Amanda, amanda.pierce@fake.com
      \t\t  Previous Token Balance, 24
      \t\t  New Token Balance 95
      \t\tBeck, Terra, terra.beck@demo.com
      \t\t  Previous Token Balance, 41
      \t\t  New Token Balance 112
    USERS_INFO

    assert_equal expected.rstrip, of.users_info("\tCustom Header:", company, users)
  end

  def test_users_info_only_header_if_no_users
    company = {
      id: 1,
      name: "Blue Cat Inc.",
      top_up: 71,
    }
    users = []
    header = "\tCustom Header:"
    of = OutputFormatter.new([company], users)

    assert_equal header, of.users_info(header, company, users)
  end
end
