require_relative 'lib/questionnaire'
require 'yaml'
require 'optparse'

def flatten_responses(nested_hash, flat_hash = {})
  return flat_hash unless nested_hash.is_a?(Hash)
  nested_hash.each do |section, data|
    if data.is_a?(Hash)
      flatten_responses(data, flat_hash)
    else
      flat_hash[section] = data
    end
  end
  flat_hash
end


# Parse command-line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby questionnaire.rb --config FILE1.yaml,FILE2.yaml --responses FILE.yaml"

  opts.on("--config x,y,z", Array, "Configuration YAML files") do |list|
    options[:config_files] = list
  end

  opts.on("--responses FILE", "User response YAML file") do |file|
    options[:response_file] = file
  end
end.parse!

unless options[:config_files] && options[:response_file]
  puts "Please specify --config and --responses"
  exit
end

# Load questionnaires
questionnaires = options[:config_files].map do |file|
  Questionnaire.load_and_validate_from_yaml(file)
end

nested_responses = YAML.load_file(options[:response_file])
responses = flatten_responses(nested_responses)

# Print each questionnaire
### Iterate through each questionnaire and print questions, in this case from user_response.yaml file, works without user response to
puts "===== Questionnaire Summary ====="
puts "Total Questionnaires: #{questionnaires.size}"
puts "\n"
puts "===== Questions ====="
puts "Total Questions: #{questionnaires.map(&:questions).flatten.size}"
puts "\n"
puts "===== User Responses ====="
puts "Total User Responses: #{responses.size}"
puts "\n"

# Print each questionnaire title and its questions
questionnaires.each do |q|
  puts "===== #{q.title} ====="
  q.questions.each do |question|
    # Print only if question is visible according to its conditions
    question.print_question(responses)
  end
  puts "\n"
end
