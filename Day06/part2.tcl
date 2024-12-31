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

    set data [exec cat $file]
    set lines [split $data "\n"]

    # Convert to 2-D grid
    set grid [make_grid_from_lines $lines]

    set loc [find_start_loc $grid]
    
    # Replace starting "^" with a "X"
    lset grid {*}$loc "X"
    set dir {-1 0}

    return [list $grid $loc $dir]
}

proc find_start_loc {grid} {
    set r   [lsearch $grid "*^*"]
    set c   [lsearch [lindex $grid $r] "^"]
    set loc [list $r $c]
    return $loc
}

# Move the guard one step:
proc move_one_step {grid_var loc_var dir_var "verbose 0"} {
    upvar $grid_var grid
    upvar $loc_var  loc
    upvar $dir_var  dir

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
        # print_grid $grid
        return "1"
    } else {
        set loc $next_loc
        lset grid {*}$loc $dir_char
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

proc part2 {} {
    # set input_file demo.txt
    set input_file input.txt

    # Initialize and save grid
    lassign [init_grid $input_file] grid loc dir
    set start_loc $loc

    set num_inf_loops 0
    set obstacle_skip_locs [dict create]
    dict set obstacle_skip_locs $start_loc 1
    while {1} {
        # Make a copy of the current state of the grid
        set what_if_grid $grid
        set what_if_loc  $loc
        set what_if_dir  $dir

        # Look ahead one step.   
        #   - If out of bounds, stop.
        set obs_loc   [+ $what_if_loc $what_if_dir]
        set next_char [lindex $what_if_grid {*}$obs_loc]

        if {$next_char eq ""} {
            puts "Main loop out of bounds"
            break
        } elseif {$next_char eq "#"} {
            set what_if_dir  [* $what_if_dir "0 -1"]
            set obs_loc      [+ $what_if_loc $what_if_dir]
        } 

        if {[dict exists $obstacle_skip_locs $obs_loc]} {
            # Do nothing.  Cannot put an obstacle at start or a place previously tested.
        } else {
            # Place an obstacle in the what-if grid and run test.
            dict set obstacle_skip_locs $obs_loc 1
            lset what_if_grid {*}$obs_loc "O"
            while {1} {
                # 0: out of bounds
                # 1: infinite what_if
                # 2: keep going
                set move_status [move_one_step what_if_grid what_if_loc what_if_dir]
                if {$move_status == 0} {
                    # out of bounds
                    break 
                } elseif {$move_status == 1} {
                    # infinite loop
                    incr num_inf_loops 
                    puts "-----------------------------"
                    puts "Infinite loop $num_inf_loops"
                    # print_grid $what_if_grid
                    break
                }
            }
        }

        # Take one step in the main loop's grid
        set move_status [move_one_step grid loc dir]
        if {$move_status in "0 1"} {
            break
        }

    }

    puts "Part2 answer = $num_inf_loops"
}

time {part2}




