# Advent of Code 2024.  
# Day 10: Hoof It
# Part 1: Get the score of every trailhead

package require math::complexnumbers
namespace import math::complexnumbers::*

source ../aoc_library.tcl


# set data [exec cat demo.txt]
set data  [exec cat input.txt]

set lines [split $data "\n"]
set grid  [make_grid_from_lines $lines]

# Define the cache (a list of nine locations per grid location)
#   - key = grid location
#   - value list of locations:  but each location will be represented as "row:col" to 
#       avoid ambiguity between lists and lists of lists.
set nines_per_loc [dict create]

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

# Find the 9's that a location can lead to.
#   Recursive proc:  The score of a trailhead is the sum of the four neighbors.
#   Don't repeat yourself.  Use a cache (aka memoization)
proc get_nines {grid loc} {
    global nines_per_loc

    
    # Have we already looked at this location?
    if {[dict exists $nines_per_loc $loc]} {
        return [dict get $nines_per_loc $loc]
    }

    set nines [list]
    # A "9" returns a list with its own location
    set current_val [lindex $grid {*}$loc]
    if {$current_val == 9} {
        set result [join $loc ":"]
        dict set nines_per_loc $loc $result
        puts "Nine at {$loc}"
        return $result
    }

    # Otherwise, recurse by checking the 'nines' of the neighbors matching the target.
    set target_val  [expr {$current_val + 1}]
    foreach dir [list {1 0} {0 1} {-1 0} {0 -1}] {
        set neighbor_loc [+ $loc $dir]
        set neighbor_val [lindex $grid {*}$neighbor_loc]
        if {$neighbor_val == $target_val} {
            # puts "Loc = {$loc}  Neighbor = {$neighbor_loc}"
            lappend nines {*}[get_nines $grid $neighbor_loc]
        }
    }
    set nines [lsort -unique $nines]

    dict set nines_per_loc $loc $nines
    return $nines
}

set trailheads [lsearch_grid $grid 0]

set part1_ans 0
foreach trailhead $trailheads {
    set score [llength [get_nines $grid $trailhead]]
    puts "Trailhead : $trailhead (score = $score)"
    incr part1_ans $score
}
puts "Part1 answer = $part1_ans"



