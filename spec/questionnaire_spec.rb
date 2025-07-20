require 'rspec'
require 'yaml'
require 'tempfile'
require_relative '../lib/questionnaire'
require_relative '../lib/question'

RSpec.describe Questionnaire do
  let(:sample_yaml) do
    {
      'title' => 'Sample Questionnaire',
      'questions' => [
        {
          'id' => 'q1',
          'text' => 'What is your name?',
          'type' => 'text',
          'config' => { 'min_length' => 2, 'max_length' => 50 }
        },
        {
          'id' => 'q2',
          'text' => 'Do you have an Alias?',
          'type' => 'boolean'
        }
      ]
    }.to_yaml
  end

  describe '.load_from_yaml' do
    it 'loads a questionnaire from a YAML file' do
      # Write sample YAML to a temp file
      Tempfile.open(['questionnaire', '.yaml']) do |file|
        file.write(sample_yaml)
        file.rewind
        questionnaire = Questionnaire.load_from_yaml(file.path)
        expect(questionnaire).to be_a(Questionnaire)
        expect(questionnaire.title).to eq('Sample Questionnaire')
        expect(questionnaire.questions.size).to eq(2)
        expect(questionnaire.questions.first).to be_a(Question)
        expect(questionnaire.questions.first.id).to eq('q1')
      end
    end
  end

  describe '#print' do
    let(:questionnaire) do
      # Construct questions manually
      q1 = Question.new({
        'id' => 'q1',
        'text' => 'What is your name?',
        'type' => 'text',
        'config' => { 'min_length' => 2, 'max_length' => 50 }
      })
      q2 = Question.new({
        'id' => 'q2',
        'text' => 'Do you have an Alias?',
        'type' => 'boolean'
      })
      Questionnaire.new(title: 'Test Questionnaire', questions: [q1, q2])
    end

    it 'prints questionnaire questions with responses' do
      responses = {
        'q1' => 'Alice',
        'q2' => false
      }

      # Capture stdout
      output = StringIO.new
      $stdout = output

      questionnaire.print(responses)

      $stdout = STDOUT
      output_str = output.string

      expect(output_str).to include('=== Test Questionnaire ===')
      expect(output_str).to include('What is your name?')
      expect(output_str).to include('Alice')
      expect(output_str).to include('Do you have an Alias?')
      expect(output_str).to include('(x) No')
    end
  end
end
