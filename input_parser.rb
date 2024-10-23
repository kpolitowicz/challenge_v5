require "json"

# Usage: `InputParser.parse_json(file_name)`
class InputParser
  class Error < StandardError; end

  def parse_json(file)
    # Note: would use `.map(&:symbolize_keys)` with active_support
    JSON.parse(File.read(file)).map { |hash| hash.transform_keys(&:to_sym) }
  rescue Errno::ENOENT => e # add any additional exception from File.read here
    raise Error, "Could not read the file: #{e}"
  rescue JSON::ParserError => e
    raise Error, "Could not parse #{file} file: #{e}"
  end
end
