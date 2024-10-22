require "json"

class InputParser
  def self.read_and_parse(file)
    # Note: would use `.map(&:symbolize_keys)` with active_support
    JSON.parse(File.read(file)).map { |hash| hash.transform_keys(&:to_sym) }
  end
end
