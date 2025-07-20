require_relative 'question'
require_relative 'condition'
require 'yaml'
require 'json'
require 'json-schema'

class Questionnaire
  attr_reader :title, :questions

  def initialize(title:, questions:)
    @title = title
    @questions = questions
  end

  def self.load_from_yaml(file_path)
    data = YAML.load_file(file_path)
    questions = data['questions'].map { |q| Question.new(q) }
    new(title: data['title'], questions: questions)
  end

  def self.load_and_validate_from_yaml(file_path)
    # Load the JSON Schema
    schema = JSON.parse(File.read('schema/questionnaire_schema.json'))
    # Validate the schema file exists
    unless File.exist?('schema/questionnaire_schema.json')
      raise "Schema file not found"
    end
    # Validate the schema structure
    unless schema.is_a?(Hash) && schema['$schema'] == 'http://json-schema.org/draft-06/schema#'
      raise "Invalid schema format"
    end
    # Validate the YAML file path is provided
    unless file_path && !file_path.empty?
      raise "YAML file path is required"
    end
    # Validate the YAML file exists
    unless File.exist?(file_path)
      raise "YAML file not found"
    end
    # Validate the YAML file is readable
    unless File.readable?(file_path)
      raise "YAML file is not readable"
    end
    # Validate the YAML file is not empty
    if File.zero?(file_path)
      raise "YAML file is empty"
    end
    # Validate the YAML file content
    begin
      data = YAML.load_file(file_path)
    rescue Psych::SyntaxError => e
      raise "YAML syntax error: #{e.message}"
    end
    # Check required fields
    unless data.is_a?(Hash) && data.key?('title') && data.key?('questions')
      raise "Missing required fields"
    end
    # Check questions is an array
    unless data['questions'].is_a?(Array)
      raise "Questions must be an array"
    end
    # Check each question has required fields
    data['questions'].each do |question|
      unless question.is_a?(Hash) && question.key?('id') && question.key?('text')
        raise "Invalid question format"
      end
    end
    # Convert YAML data to JSON for validation
    # Validate the YAML file content against the schema
    unless data.is_a?(Hash) && data.key?('title') && data.key?('questions')
      raise "YAML file must contain 'title' and 'questions' keys"
    end
    # Validate questions is an array
    unless data['questions'].is_a?(Array)
      raise "'questions' must be an array"
    end
    # Validate each question has required fields
    data['questions'].each do |question|
      unless question.is_a?(Hash) && question.key?('id') && question.key?('text')
        raise "Each question must have 'id' and 'text' fields"
      end
    end

    # Validate the YAML file against the schema
    data = YAML.load_file(file_path)
    json_data = data.to_json
    errors = JSON::Validator.fully_validate(schema, json_data)
    unless errors.empty?
      raise "Validation errors: #{errors.join('; ')}"
    end
    questions = data['questions'].map { |q| Question.new(q) }
    new(title: data['title'], questions: questions)
  end

  # Render questionnaire based on responses
  def print(responses = {})
    puts "=== #{@title} ==="
    @questions.each do |question|
      question.print_question(responses)
    end
  end

  # Collect responses from user input
  def collect_responses(responses = {})
    @questions.each do |question|
      next unless question.visible?(responses)
      answer = question.ask_question
      responses[question.id] = answer
    end
    responses
  end
end
