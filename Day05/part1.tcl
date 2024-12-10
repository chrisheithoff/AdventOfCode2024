# Advent of Code 2024.  
# Day 05: Print Queue
# Part 1:  Add middle numbers of correctly sorted lists.

source ../aoc_library.tcl

set data [file_to_list_of_lists input.txt]

set rules [lindex $data 0]
set lists [lindex $data 1]

proc sort_list_part1 {a b} {
    foreach rule $::rules {
        lassign [split $rule "|"] first second
        if {$a == $first && $b == $second} {
            return -1
        } elseif {$b == $first && $a == $second} {
            return  1
        } 
    }
}

set sum 0
foreach list $lists {
    set list [split $list ","]
    if {$list == [lsort -command sort_list_part1 $list]} {
        set middle [lindex $list [expr {([llength $list] -1) / 2}]]
        incr sum $middle
    }
}

puts "Part1 answer  = $sum"

