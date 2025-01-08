# Advent of Code 2024.  
# Day 08: Resident Collinearity
# Part 1:  How many antinodes are in the grid?

package require math::complexnumbers
namespace import math::complexnumbers::*

source ../aoc_library.tcl

# Use complex number math to add and subtract 2D vectors
proc get_antinodes {a b} {
    set antinodes [list]

    set delta [- $a $b]
    lappend antinodes [+ $a $delta]
    lappend antinodes [- $b $delta]

    return $antinodes
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

            foreach antinode [get_antinodes $loc1 $loc2] {
                if {[lindex $grid {*}$antinode] != ""} {
                    puts "$antinode"
                    lset grid {*}$antinode "#"
                    lappend antinodes_list $antinode
                }
            }
        }
    }
}

print_grid $grid
set antinodes_list [lsort -u $antinodes_list]
set num_antinodes  [llength $antinodes_list]
puts "Part1 answer = $num_antinodes"
