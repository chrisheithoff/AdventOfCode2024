# Advent of Code 2024.  
# Day 10: Hoof It
# Part 2: Get the ranking of every trailhead.   How many unique paths per trailhead?

package require math::complexnumbers
namespace import math::complexnumbers::*

source ../aoc_library.tcl


# set data [exec cat demo.txt]
set data  [exec cat input.txt]

set lines [split $data "\n"]
set grid  [make_grid_from_lines $lines]

# Initialize the cache
set ranking_per_loc [dict create]

proc lsearch_grid {grid match} {

    set matches [list]
    foreach {r row} [enumerate $grid] {
        foreach {c char} [enumerate $row] {
            if {$char == $match} {
                lappend matches [list $r $c]
            }
        }
    }
    return $matches
}

# How many unique paths to a '9' for a location?
#   Recursive proc plus memoization
proc get_ranking {grid loc} {
    global ranking_per_loc

    # Have we already looked at this location?
    if {[dict exists $ranking_per_loc $loc]} {
        return [dict get $ranking_per_loc $loc]
    }


    # No need to recurse for 9.  Just return 1.
    set current_val [lindex $grid {*}$loc]
    if {$current_val == 9} {
        dict set ranking_per_loc $loc 1
        # puts "Nine at {$loc}"
        return 1
    } 


    # Otherwise, recurse by checking rankings of the neighbors that meet the target
    set ranking 0
    set target_val  [expr {$current_val + 1}]
    foreach dir [list {1 0} {0 1} {-1 0} {0 -1}] {
        set neighbor_loc [+ $loc $dir]
        set neighbor_val [lindex $grid {*}$neighbor_loc]
        if {$neighbor_val == $target_val} {
            incr ranking [get_ranking $grid $neighbor_loc]
        }
    }

    dict set ranking_per_loc $loc $ranking
    return $ranking
}

set trailheads [lsearch_grid $grid 0]

set part2_ans 0
foreach trailhead $trailheads {
    set ranking [get_ranking $grid $trailhead]
    # puts "Trailhead : $trailhead (ranking = $ranking)"
    incr part2_ans $ranking
}
puts "Part2 answer = $part2_ans"



