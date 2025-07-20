require_relative 'lib/questionnaire'
require 'yaml'
require 'optparse'

def flatten_responses(nested_hash, flat_hash = {})
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
  Questionnaire.load_from_yaml(file)
end

nested_responses = YAML.load_file(options[:response_file])
responses = flatten_responses(nested_responses)

# Print each questionnaire
questionnaires.each do |q|
  q.questions.each do |question|
    # Print only if question is visible according to its conditions
    question.print_question(responses)
  end
  puts "\n"
end
