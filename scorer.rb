# encoding: utf-8
class Scorer

  def initialize(requirements, main_requirement_label)
    @requirements = requirements
    @main_requirement_label = main_requirement_label
  end

  # Get the summed values for each requirement within supplied widget array.
  # Returns a hash where the key is the requirement and the sum is the value.
  # @param [array] widget_array
  def get_values(widget_array)
    values_hash = {}
    @requirements.each { |req, value| values_hash[req] = 0 }
    widget_array.each do |widget|
      @requirements.each do |requirement, value|
        values_hash[requirement] += widget.send(requirement)
      end
    end
    return values_hash
  end

  # Get the score of the array. Each requirement is subtracted current
  # value, so scores less than or equal to 0 are filled requirements. Return
  # a hash where key is the requirement and value is the score.
  def get_score_hash(widget_array)
    values = get_values(widget_array)
    score_hash = {}
    @requirements.each { |req, value| score_hash[req] = value - values[req] }
    return score_hash
  end

  def get_total_score(score_hash)
      negatives = 0
      positives = 0
      @requirements.each do |requirement, value|
        if requirement != @main_requirement_label
          value = score_hash[requirement]
          value <= 0 ? negatives += value : positives += value
        end
      end
      positives == 0 ? score = negatives : score = positives
  end

  def get_better_score(first, second)
    if first.nil?
      return :second
    elsif second.nil?
      return :first
    elsif first == second
      return :equal
    elsif second > 0 and second > first
      return :first 
    elsif second <= 0 and first <= 0 and first > second
      return :first 
    else
      return :second
    end
  end
end
