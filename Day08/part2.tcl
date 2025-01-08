# Advent of Code 2024.  
# Day 08: Resident Collinearity
# Part 2:  How many antinodes are in the grid?  (but now more of them!)

# Use complex number math to add and subtract 2D vectors
package require math::complexnumbers
namespace import math::complexnumbers::*

source ../aoc_library.tcl

proc get_slope {a b} {

    set delta [- $b $a]
    set gcd   [gcd {*}$delta]
    set slope [/ $delta "$gcd 0"]

    return $slope
}

# set data [exec cat demo.txt]
set data  [exec cat input.txt]
set lines [split $data "\n"]
set grid  [make_grid_from_lines $lines]

# Save locations of all frequencies to a dictionary
#    key   = freq
#    value = list of locations
set freq_locs [dict create]
foreach {r row} [enumerate $grid] {
    foreach {c char} [enumerate $row] {
        if {[regexp {\w} $char]} {
            dict lappend freq_locs $char [list $r $c]
        }
    }
}

# For each frequency, derive the valid antinodes
set freqs [lsort -u [dict keys $freq_locs]]
set antinodes_list [list]
foreach freq $freqs {
    set locs     [dict get $freq_locs $freq]

    # Select any two locations of this frequency.
    foreach {i loc1} [enumerate $locs] {
        foreach {j loc2} [enumerate $locs] {
            if {$j <= $i} {continue}

            set slope [get_slope $loc1 $loc2]
            
            # Get all the antinodes from loc1 + N*slope
            set antinode $loc1
            while {1} {
                if {[lindex $grid {*}$antinode] != ""} {
                    lset grid {*}$antinode "#"
                    lappend antinodes_list $antinode
                    set antinode [+ $antinode $slope]
                } else {
                    break
                }
            }

            # Get all the antinodes from loc2 - N*slope
            set antinode $loc2
            while {1} {
                if {[lindex $grid {*}$antinode] != ""} {
                    lset grid {*}$antinode "#"
                    lappend antinodes_list $antinode
                    set antinode [- $antinode $slope]
                } else {
                    break
                }
            }

        }
    }
}

print_grid $grid
set antinodes_list [lsort -u $antinodes_list]
set num_antinodes  [llength $antinodes_list]
puts "Part2 answer = $num_antinodes"
