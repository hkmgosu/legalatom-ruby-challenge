
class Question
  attr_reader :id, :text, :type, :config, :conditions

  def initialize(data)
    @id = data['id']
    @text = data['text']
    @type = data['type']
    @config = data['config'] || {}
    @conditions = (data['conditions'] || []).map { |cond| Condition.new(cond) }
  end

  def visible?(responses)
    return true if @conditions.empty?
    evaluate_visibility(responses)
  end

  def evaluate_visibility(responses)
    # All conditions must be true for the question to be visible
    @conditions.all? { |cond| cond.evaluate(responses) }
  end

  def print_question(responses)
    return unless visible?(responses)

    case type
    when 'text'
      min_length = @config['min_length'] || 0
      max_length = @config['max_length'] || '∞'
      puts "#{@text}"
      puts "  #{ responses[@id] ? responses[@id] : '[Input]' } (min: #{min_length} chars, max: #{max_length} chars)"
    when 'boolean'
      selected_value = responses[@id]
      puts "#{@text}"
      puts "  - (#{selected_value == true ? 'x' : ' '}) Yes (value: true)"
      puts "  - (#{selected_value == false ? 'x' : ' '}) No  (value: false)"
    when 'radio'
      options = @config['options'] || []
      puts "#{@text}"
      options.each do |opt|
        selected = responses[@id] == opt['value']
        mark = selected ? 'x' : ' '
        puts "  - (#{mark}) #{opt['label']} (value: '#{opt['value']}')"
      end
    when 'checkbox'
      options = @config['options'] || []
      selected_values = responses[@id] || []
      puts "#{@text}"
      options.each do |opt|
        selected = selected_values.include?(opt['value'])
        mark = selected ? 'x' : ' '
        puts "  - [#{mark}] #{opt['label']} (value: '#{opt['value']}')"
      end
    when 'dropdown'
      options = @config['options'] || []
      selected_value = responses[@id]
      puts "#{@text}"
      options.each do |opt|
        selected = selected_value == opt['value']
        mark = selected ? '<x>' : '< >'
        puts "  #{mark} #{opt['label']} (value: '#{opt['value']}')"
      end
    else
      puts "#{@text}"
    end
  end
end
