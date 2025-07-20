# lib/condition.rb
class Condition
  def initialize(data)
    @type = data['type']
    @question_id = data['question_id']
    @value = data['value']
    @conditions = data['conditions']
  end

  def evaluate(responses)
    case @type
    when 'value_check'
      responses[@question_id] == @value
    when 'not'
      @conditions.all? { |cond| Condition.new(cond).evaluate(responses) } ? false : true
    # Add other condition types as needed
    else
      false
    end
  end
end
