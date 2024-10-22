require "minitest/autorun"

require_relative "challenge"

class ChallengeTest < Minitest::Test
  def test_initializes_line_with_input
    line = Line.new("1abc2")
    assert_equal "1abc2", line.input
  end
end
