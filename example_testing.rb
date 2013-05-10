require './widget.rb'
require_relative 'branch_bound_example'
require 'benchmark'

def enumerate_possible(current_branch,working_set)
  possible_combos=[]
  while working_set.size > 0
    added_array=current_branch+[working_set[0]]
    score_hash=get_score_hash(added_array)
    if score_hash[:size] >= 0
      possible_combos+=[added_array]
      possible_combos+=enumerate_possible(added_array,working_set.dup)
    end
      working_set.shift
    end
  return possible_combos
end

@requirement_size=90
@requirement_power_a=250
@requirement_power_b=200
@requirement_power_c=100
@requirements_of_interest=[:power_a,:power_b,:power_c]

widget_x=Widget.new("X",15, 90, 20, 80)
widget_y=Widget.new("Y",10, 70, 50, 10)
widget_z=Widget.new("Z",20, 100, 150, 50)

all_widgets=[widget_x,widget_y,widget_z]
best_score_sets=[[widget_z]]
best_score=get_total_score(get_score_hash(best_score_sets[0]))

time=Benchmark.bm(7) do |x|
  x.report("brute:") do
      all_possible_sets=enumerate_possible([],all_widgets)
      all_possible_sets.each do |set|
          score=get_total_score(get_score_hash(set))
          if score == best_score
            best_score_sets.push(set)
          elsif best_score > 0 and best_score > score
            best_score=score
            best_score_sets=[set]
          elsif best_score <= 0 and score <=0 and score > best_score
            best_score=score
            best_score_sets=[set]
          end
      end
  end
end

best_score_sets.each { |set| print_widget_array set}
puts "Score: "+best_score.to_s
puts time

