require "json"

class InputParser
  class Error < StandardError ; end

  def self.read_and_parse(file)
    # Note: would use `.map(&:symbolize_keys)` with active_support
    JSON.parse(File.read(file)).map { |hash| hash.transform_keys(&:to_sym) }
  rescue Errno::ENOENT => e # add any additional exception from File.read here
    raise Error, "Could not read the file: #{e}"
  rescue JSON::ParserError => e
    raise Error, "Could not parse the file: #{e}"
  end
end
