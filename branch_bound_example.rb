require './widget'
require './requirements'
require 'benchmark'


#Print out the widgets that make up an array
def print_widget_array(widget_array)
  name_string="[ "
  widget_array.each_with_index do |widget,index|
     name_string+=widget.name
     if index < widget_array.length-1
     name_string+=","
     end
  end
  puts name_string+" ]"
end

#Get the summed values for each requirement within supplied widget array.
#Returns a hash where the key is the requirement and the sum is the value.
# @param [array] widget_array
def get_values(widget_array)
  values_hash={:size => 0}
  @requirements_of_interest.each { |req| values_hash[req]= 0 }
  widget_array.each do |widget|
    values_hash[:size]+=widget.size
    @requirements_of_interest.each do |requirement|
      values_hash[requirement]+=widget.send(requirement)
    end
  end
  return values_hash
end

#Get the score of the array. Each requirement is subtracted from the current
#value, so scores less than or equal to 0 are filled requirements. Return a hash
#where key is the requirement and value is the score.
def get_score_hash(widget_array)
  values=get_values(widget_array)
  score_hash={ :size => @requirement_size - values[:size] }
  @requirements_of_interest.each do |requirement|
      score_hash[requirement]=(instance_variable_get("@requirement_#{requirement}") -
               values[requirement])
  end
  return score_hash
end

#Calculate the total score of the array. -1 indicates that the array is too
#large for the size requirement and therefore invalid. 0 or greater numbers for
#score are sum of each absolute distance for each value from its given requirement.
#Lower scores are better fits.
def get_total_score(score_hash)
    negatives=0
    positives=0
    @requirements_of_interest.each do |requirement|
      value=score_hash[requirement]
      value <= 0 ? negatives+=value : positives+=value
    end
    positives == 0 ? score=negatives : score=positives
end

#Determines if the first provided score is better than the second provided
#score. If it is a 1 is returned, if not a -1, if they are equal a 0 is
#returned.
def score_is_better(first,second)
  if first == second
    return 0
  elsif second > 0 and second > first
    return 1
  elsif second <= 0 and first <=0 and first > second
    return 1
  else
    return -1
  end
end

#Given a widget_array first calculate it's score, and add it as a branch in the
#list of branches based on the quality of it's score. Better scores are first.
#Branches that do not meet the size requirement are not added to the branches
#array. This effectively kills that branch.
def add_branch(widget_array,branches)
  score_hash=get_score_hash widget_array
  score=get_total_score score_hash
  added=false
  branches_index=0
  if score_hash[:size] >= 0 
    while not added and branches_index < branches.length do
      if score_is_better(score,branches[branches_index][1]) >= 0
          branches.insert(branches_index,[score_hash,score,widget_array])
          added=true
      end
      branches_index+=1
    end
    if not added
      branches.push([score_hash,score,widget_array])
    end
  end
end

#Branch and bound recursive search. Provided an in array which represents the
#node which will be branched off of. Roughly, the function first creates a list
#of potential branches which are ordered by the quality of their score.
#Potential branches are then looped through, if a potential branch is viable the
#function is called again with it as the root node. This continues until
#exhaustion of all possiblities.

def branch_and_bound(in_array)
  branches=[]
  @all_widgets.each do |widget|
    branch_array=in_array+[widget]
    add_branch(branch_array,branches)  
  end
  
  branches.each do |branch|
    score_hash=branch[0]
    score=branch[1]
    widget_array=branch[2]
    score_comparison=score_is_better(score,@best_solution_score)
    if score_comparison == 0 
      @best_solution.push(widget_array)
      continue_branch_investigation=true
    elsif score_comparison == 1
      @best_solution=[widget_array]
      @best_solution_score=score
      continue_branch_investigation=true
    else
      if score > 0 
        continue_branch_investigation=true
      end
    end
    if continue_branch_investigation
      branch_and_bound(widget_array)
    end
  end
end

### Environment setup and benchmarking of algorithm 

@requirement_power_a=250
@requirement_power_b=200
@requirement_power_c=100
@requirements_of_interest=[:power_a,:power_b,:power_c]

widget_x=Widget.new("X",15, 90, 20, 80)
widget_y=Widget.new("Y",10, 70, 50, 10)
widget_z=Widget.new("Z",20, 100, 150, 50)

@all_widgets=[widget_x,widget_y,widget_z]


##Run branch and bound with a smaller search size, 90
@requirement_size=90
@best_solution=[[widget_y]]
@best_solution_score=get_total_score(get_score_hash(@best_solution[0]))
time=Benchmark.bm(7) { |x|
  x.report("b&b[90]:"){
    branch_and_bound([])
  }

}

@best_solution.each { |solution| print_widget_array solution}

##Run branch and bound with a larger search size, 400
@requirement_size=400
@best_solution=[[widget_y]]
@best_solution_score=get_total_score(get_score_hash(@best_solution[0]))
time=Benchmark.bm(7) { |x|
  x.report("b&b[400]:"){
    branch_and_bound([])
  }

}
@best_solution.each { |solution| print_widget_array solution}
