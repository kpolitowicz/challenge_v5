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
end
