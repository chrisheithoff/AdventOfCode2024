# Advent of Code 2024.  
# Day 01:  Historian Hysteria
# Part 1:  Total distance between sorted lists.

set listA [list]
set listB [list]

set data [exec cat input.txt]
foreach {a b} $data {
    lappend listA $a
    lappend listB $b
}

set listA [lsort -increasing -integer $listA]
set listB [lsort -increasing -integer $listB]

set sum 0
foreach a $listA b $listB {
    incr sum [expr {abs($a - $b)}]
}

puts "Part1 answer = $sum"


