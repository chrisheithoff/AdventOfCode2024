# Advent of Code 2024.  
# Day 06: Guard Gallivent
# Part 2: How many locations can cause an infinite loop if an object were placed there?

# Use complex numbers to simplify two-dimensional stuff
#   - location is a complex number (row, col) = x + yi
#   - add a direction to a location to make new location
#   - multiply by i to rotate a direction
package require math::complexnumbers
namespace import math::complexnumbers::*

source ../aoc_library.tcl


proc init_grid {file} {
    global grid loc dir 

    set data [exec cat $file]
    set lines [split $data "\n"]

    # Convert to 2-D grid
    set grid [make_grid_from_lines $lines]

    set loc [find_start_loc $grid]
    set dir {-1 0}

    return $grid
}

proc find_start_loc {grid} {
    set r   [lsearch $grid "*^*"]
    set c   [lsearch [lindex $grid $r] "^"]
    set loc [list $r $c]
    return $loc
}

# Move the guard one step:
proc move_one_step {"verbose 0"} {
    global grid loc dir visited

    # Plan the next location
    set next_loc  [+ $loc $dir]
    set next_char [lindex $grid {*}$next_loc]

    # Check for out of bounds.  
    if {$next_char == ""} {
        # puts "The guard has left the boundary"
        return "0"
    }

    # Check for "#" or "O" obstacle.  
    #   - If so, then do a right turn
    #   - Implement by multiplying by complex "0 -1" (for this grid)
    while {$next_char in "# O"} {
        set dir       [* $dir "0 -1"]
        set next_loc  [+ $loc $dir]
        set next_char [lindex $grid {*}$next_loc]
    } 

    set dir_char [map_dir_to_char $dir]

    # Check if you've been here before in the same direction
    #   - if not, then mark the grid with the direction ^, v, < or >
    if {$next_char eq $dir_char} {
        puts ""
        puts "Infinite loop"
        # print_grid $grid
        return "1"
    } else {
        set loc $next_loc
        lset grid {*}$loc $dir_char
        if {$loc ni $visited} {
            lappend visited $loc
        }
    }

    if {$verbose} {
        puts ""
        print_grid $grid
    }
    return "2"
}

proc map_dir_to_char {dir} {
    switch $dir {
        "-1 0" {return "^"}
        "1 0"  {return "v"}
        "0 1"  {return ">"}
        "0 -1" {return "<"}
    }
}

# The move_one_step proc uses (perhaps unwisely) global variables
proc move_guard {} {

    while {1} {
        # status 0: out of bounds
        # status 1: infinite loop
        # status 2: keep going
        set move_status [move_one_step]
        if {$move_status in "0 1"} {
            return $move_status
        }
    }
}

#### initialize global variables
# set input_file demo.txt
set input_file input.txt


set grid [init_grid $input_file]
set start_loc $loc
set start_dir [complex -1 0]
set orig_grid $grid
set visited [list]

# Do initial solution without any additional obstruction
move_guard 

# For each visited location, see if an obstacle leads to infinite loop
set infinite_obs_locs 0
foreach {i obs_loc} [enumerate $visited 1] {
    if {$obs_loc == $start_loc} {
        continue
    }

    # Rewind to original conditions
    set grid $orig_grid
    set loc  $start_loc
    set dir  $start_dir
    
    # Add the objstacle
    lset grid {*}$obs_loc "O"

    # [move_guard] will return 1 for an infinite loop
    incr infinite_obs_locs [move_guard]
    puts ""
    puts "#### $i:  $infinite_obs_locs #####"
    # print_grid $grid
    # if {$infinite_obs_locs == 1} {
        # break
    # }
}
puts "Part2 answer = $infinite_obs_locs"
    




