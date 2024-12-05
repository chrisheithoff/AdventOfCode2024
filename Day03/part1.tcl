# Advent of Code 2024.  
# Day 03: Mull It Over
# Part 1: How Many mul(#,#) commands are in the string?

# set data [exec cat demo.txt]
set data [exec cat input.txt]

# regexp 
#    -all     : find ALL possible matches
#    -inline  : return the list of matches, included capture groups
#    \(  \)   : literal parentheses
#     (   )   : capture parentheses
#     \((\d+),(\d+)\)  :   capture the integers in the parentheses
#
#  This returns a list:  {match1 d1a d1b match2 d2a d2b ....}
set mul_cmds [regexp -all -inline {mul\((\d+),(\d+)\)} $data]

set part1_answer 0
foreach {_ a b} $mul_cmds {
    set product [expr {$a * $b}]
    incr part1_answer $product

}

puts "Part1 answer: $part1_answer"
