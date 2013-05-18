# encoding: utf-8
class BruteSearch
  @best_score = nil
  @best_combo = nil

  def initialize(scorer, main_requirement_label)
    @scorer = scorer
    @main_requirement = main_requirement_label
  end

  def enumerate_possible(current_branch, working_set)
    possible_combos = []
    while working_set.size > 0
      added_array = current_branch + [working_set[0]]
      score_hash = @scorer.get_score_hash(added_array)
      total_score = @scorer.get_total_score(score_hash)
      if score_hash[@main_requirement] >= 0
        if @scorer.get_better_score(total_score, @best_score) == 1
          @best_score = total_score
          @best_combo = added_array
        end
        possible_combos += [added_array]
        possible_combos += enumerate_possible(added_array, working_set.dup)
      end
        working_set.shift
    end
    return possible_combos
  end

  def get_best_score
    return @best_score, @best_combo
  end
end
