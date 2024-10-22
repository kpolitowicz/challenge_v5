require "minitest/autorun"

require_relative "input_parser"

class InputParserTest < Minitest::Test
  def test_reads_and_parses_valid_json_file
    expected = [{
      id: 1,
      name: "Dean"
    }, {
      id: 2,
      name: "Sam"
    }]
    assert_equal expected, InputParser.read_and_parse("./fixtures/valid.json")
  end

  def test_reports_problem_with_file_read
    assert_raises(InputParser::Error) { InputParser.read_and_parse("./fixtures/missing.json") }
  end

  def test_reports_problem_with_file_read
    assert_raises(InputParser::Error) { InputParser.read_and_parse("./fixtures/invalid.json") }
  end
end
