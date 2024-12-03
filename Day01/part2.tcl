# Advent of Code 2024.  
# Day 01:  Historian Hysteria
# Part 2:  Similarity Score

set listA [list]
set listB [list]

set data [exec cat input.txt]
foreach {a b} $data {
    lappend listA $a
    lappend listB $b
}

set score_dict [dict create]
# Count occurrences of each number in listB
foreach b $listB {
    dict incr score_dict $b
}

# Multiply each number in listA by the number of occurrences in listB
set sum 0
foreach a $listA {
    if {[dict exists $score_dict $a]} {
        incr sum [expr {$a * [dict get $score_dict $a]}]
    }
}

puts "Part2 answer = $sum"


