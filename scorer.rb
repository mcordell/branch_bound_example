
class Scorer

  def initialize(requirements,main_requirement_label)
    @requirements=requirements
    @main_requirement_label=main_requirement_label
  end

  #Get the summed values for each requirement within supplied widget array.
  #Returns a hash where the key is the requirement and the sum is the value.
  # @param [array] widget_array
  def get_values(widget_array)
    values_hash={}
    @requirements.each { |req,value| values_hash[req]= 0 }
    widget_array.each do |widget|
      @requirements.each do |requirement,value|
        values_hash[requirement]+=widget.send(requirement)
      end
    end
    return values_hash
  end

  #Get the score of the array. Each requirement is subtracted current
  #value, so scores less than or equal to 0 are filled requirements. Return a hash
  #where key is the requirement and value is the score.
  def get_score_hash(widget_array)
    values=get_values(widget_array)
    score_hash={}
    @requirements.each { |requirement,value| score_hash[requirement]= value - values[requirement] }
    return score_hash
  end

  def get_total_score(score_hash)
      negatives=0
      positives=0
      @requirements.each do |requirement,value|
        if requirement != @main_requirement_label
        value=score_hash[requirement]
        value <= 0 ? negatives+=value : positives+=value
          end
      end
      positives == 0 ? score=negatives : score=positives
  end

  def get_better_score(first,second)
    if first.nil?
      return -1
    elsif second.nil?
      return 1
    elsif first == second
      return 0
    elsif second > 0 and second > first
      return 1
    elsif second <= 0 and first <=0 and first > second
      return 1
    else
      return -1
    end
  end
end
