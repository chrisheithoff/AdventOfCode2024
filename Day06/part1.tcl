# Advent of Code 2024.  
# Day 06: Guard Gallivent
# Part 1:  How many squares will the guard visit?

# Use complex numbers to simplify two-dimensional stuff
#   - location is a complex number (row, col) = x + yi
#   - add a direction to a location to make new location
#   - multiply by i to rotate a direction
package require math::complexnumbers
namespace import math::complexnumbers::*

source ../aoc_library.tcl

# set data [exec cat demo.txt]
set data [exec cat input.txt]

set lines [split $data "\n"]

# Convert to 2-D grid
set grid [make_grid_from_lines $lines]

# Locate the starting point of the guard. Mark with an 'X'
set r   [lsearch $grid "*^*"]
set c   [lsearch [lindex $grid $r] "^"]
set loc [list $r $c]
lset grid {*}$loc "X"

# Starting direction is "up". This moves to the previous row.
set dir "-1 0"

# Move the guard one step:
proc move_one_step {"verbose 0"} {
    global grid loc dir 

    # Plan the next location
    set next_loc  [+ $loc $dir]
    set next_char [lindex $grid {*}$next_loc]

    # Check for out of bounds.  If so, return two levels up the stack (not just 1)
    if {$next_char == ""} {
        return -level 2
    }

    # Check for "#" obstacle.  
    #   - If so, then do a right turn
    #   - Implement by multiplying by complex "0 -1" (for this grid)
    if {$next_char eq "#"} {
        set dir      [* $dir "0 -1"]
        set next_loc [+ $loc $dir]
    } 

    # Move 
    set loc $next_loc
    lset grid {*}$loc "X"

    if {$verbose} {
        print_grid $grid
    }

    return
}

# The move_one_step proc will return two levels up the stack 
# when the guard moves out of bounds.
proc move_guard {} {
    while {1} {
        move_one_step
    }
}

# How many unique spaces have been visited?
move_guard
set num_visited [regexp -all {X} $grid]
puts "Part1 answer = $num_visited"
    




