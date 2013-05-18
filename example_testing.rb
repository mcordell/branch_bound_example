# encoding: utf-8
require_relative 'widget'
require_relative 'branch_bound'
require_relative 'brute'
require_relative 'scorer'
require 'benchmark'

def widget_array_to_s(widget_array)
  name_string = '[ '
  widget_array.each_with_index do |widget, index|
    name_string += widget.name
    name_string += ', ' if index < widget_array.length - 1
  end
  name_string += ' ]'
end

requirements_90 = { size: 90, power_a: 250, power_b: 200, power_c: 100 }
requirements_400 = { size: 400, power_a: 250, power_b: 200, power_c: 100 }
widget_x = Widget.new('X', 15, 90, 20, 80)
widget_y = Widget.new('Y', 10, 70, 50, 10)
widget_z = Widget.new('Z', 20, 100, 150, 50)
all_widgets = [widget_x, widget_y, widget_z]

best_score_90 = nil
best_set_90 = []
best_score_90_bb = nil
best_set_90_bb = []
best_score_400 = nil
best_set_400 = []
best_score_400_bb = nil
best_set_400_bb = []
time = Benchmark.bm(7) do |x|
  x.report('brute[90]:') do
    scorer = Scorer.new(requirements_90, :size)
    brute = BruteSearch.new(scorer, :size)
    possible_combos = brute.enumerate_possible([], all_widgets.dup)
    best_score_90, best_set_90 = brute.get_best_score
  end
  x.report('brute[400]:') do
    scorer = Scorer.new(requirements_400, :size)
    brute = BruteSearch.new(scorer, :size)
    possible_combos = brute.enumerate_possible([], all_widgets.dup)
    best_score_400, best_set_400 = brute.get_best_score
  end
  x.report('b&b[90]:') do
    scorer = Scorer.new(requirements_90, :size)
    bb = BranchBoundSearch.new(scorer, :size, all_widgets)
    bb.branch_and_bound([])
    best_score_90_bb, best_set_90_bb = bb.get_best_score
  end
  x.report('b&b[400]:') do
    scorer = Scorer.new(requirements_400, :size)
    bb = BranchBoundSearch.new(scorer, :size, all_widgets)
    bb.branch_and_bound([])
    best_score_400_bb, best_set_400_bb = bb.get_best_score
  end
end

puts 'Best set [90] brute: ' + widget_array_to_s(best_set_90)
puts 'Score[90] brute: ' + best_score_90.to_s
puts 'Best set [400] brute: ' + widget_array_to_s(best_set_400)
puts 'Score[400] brute: ' + best_score_400.to_s
puts 'Best set [90] b&b:' + widget_array_to_s(best_set_90_bb[0])
puts 'Score [90] b&b:' + best_score_90_bb.to_s
puts 'Best set [400] b&b:' + widget_array_to_s(best_set_400_bb[0])
puts 'Score [400] b&b:' + best_score_400_bb.to_s
