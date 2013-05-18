#  encoding: utf-8
require_relative 'widget'
require 'benchmark'

class BranchBoundSearch
  @best_score = nil
  @best_combos = []

  def initialize(scorer, main_requirement_label, all_possible)
    @scorer = scorer
    @main_requirement_label = main_requirement_label
    @all_possible = all_possible
  end

  # Given a widget_array first calculate it's score,  and add it as a branch
  # in the list of branches based on the quality of it's score. Better
  # scores are first. Branches that do not meet the size requirement
  # are not added to the branches array. This effectively kills that branch.
  def add_branch(widget_array, branches)
    score_hash = @scorer.get_score_hash(widget_array)
    score = @scorer.get_total_score(score_hash)
    added = false
    branches_index = 0
    if score_hash[@main_requirement_label] >= 0
      while !added && branches_index < branches.length do
        better_value=@scorer.get_better_score(score, branches[branches_index][1])
        if  better_value == :equal || better_value == :first
            branches.insert(branches_index, [score_hash, score, widget_array])
            added = true
        end
        branches_index += 1
      end
      branches.push([score_hash, score, widget_array]) unless added
    end
  end

  # Branch and bound recursive search. Provided an in array which
  # represents the node which will be branched off of. Roughly, the function
  # first creates a list of potential branches which are ordered by the
  # quality of their score. Potential branches are then looped through, if
  # a potential branch is viable the function is called again with it as
  # the root node. This continues until exhaustion of all possiblities.
  def branch_and_bound(in_array)
    branches = []
    @all_possible.each do |widget|
      branch_array = in_array + [widget]
      add_branch(branch_array, branches)
    end

    branches.each do |branch|
      score = branch[1]
      widget_array = branch[2]
      score_comparison = @scorer.get_better_score(score, @best_score)
      if score_comparison == :equal
        @best_combos.push(widget_array)
        continue_branch_investigation = true
      elsif score_comparison == :first
        @best_combos = [widget_array]
        @best_score = score
        continue_branch_investigation = true
      elsif score > 0
          continue_branch_investigation = true
      end
      branch_and_bound(widget_array) if continue_branch_investigation
    end
  end

  def get_best_score
    return @best_score, @best_combos
  end

end
