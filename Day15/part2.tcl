# Advent of Code 2024.
# Day 15: Warehouse Woes
# Part 2: Now things are twice as big.
    
package require math::complexnumbers
namespace import math::complexnumbers::*

source ../aoc_library.tcl

# set data  [exec cat demo.txt]
set data  [exec cat input.txt]
set lines [split $data "\n"]
set blank_line [lsearch $lines ""]

set grid_lines [lrange $lines 0 $blank_line-1]
set map {# ## . .. @ @. O []}
set grid_lines [lmap l $grid_lines {string map $map $l}]
set grid [make_grid_from_lines $grid_lines]

set fish [lindex [lsearch_grid $grid "@"] 0]

set instructions [split [join [lrange $lines $blank_line+1 end] ""] ""]

proc get_dir {char} {
    if {$char == "v"} {
        return [list 1 0]
    } elseif {$char == "^"} {
        return [list -1 0]
    } elseif {$char == "<"} {
        return [list 0 -1]
    } elseif {$char == ">"} {
        return [list 0 1]
    }
}

proc move_fish_h {instruction} {
    global grid fish

    set dir [get_dir $instruction]
    # key = location
    #   value = character
    set can_move [dict create]
    dict set can_move $fish @

    set loc $fish
    while {1} {
        set loc  [+ $loc $dir]
        set char [lindex $grid {*}$loc]
        switch $char {
            "#" {return}
            "." {break}
            default {dict set can_move $loc $char}
        }
    }

    # Clear grid
    dict for {loc char} $can_move {
        lset grid {*}$loc "."
    }

    # Set grid
    dict for {loc char} $can_move {
        set new_loc [+ $loc $dir]
        lset grid {*}$new_loc $char
    }

    set fish [+ $fish $dir]
    
}

proc move_fish_v {instruction} {
    global grid fish

    set dir [get_dir $instruction]
    # key = location
    #   value = character
    set can_move [dict create]
    dict set can_move $fish @

    set current_row [list $fish]
    while {1} {
        # Get locations in next row that might be able to move
        set next_row_to_check [lmap loc $current_row {+ $loc $dir}]
        set num_required_dots [llength $next_row_to_check]

        # Expand left/right to get the other halves of the boxes.
        set dots 0
        set move_list [list]
        foreach next_loc $next_row_to_check {
            set next_char [lindex $grid {*}$next_loc]
            if {$next_char == "#"} {
                return
            } elseif {$next_char == "."} {
                incr dots 
            } else {
                dict set can_move $next_loc $next_char

                if {$next_char == {[} } {
                    set other_loc  [+ $next_loc "0 1"]
                    set other_char {]}
                } elseif {$next_char == {]} } {
                    set other_loc [+ $next_loc "0 -1"]
                    set other_char {[}
                }
                lappend move_list $next_loc $other_loc
                dict set can_move $other_loc $other_char
            }
        }

        # Are we allowed to move yet?
        if {$dots == $num_required_dots} {
            break
        }

        # Repeat to next row if necessary
        set current_row [lsort -unique $move_list]
    }

    # Clear grid
    dict for {loc char} $can_move {
        lset grid {*}$loc "."
    }

    # Set grid
    dict for {loc char} $can_move {
        set new_loc [+ $loc $dir]
        lset grid {*}$new_loc $char
    }

    set fish [+ $fish $dir]

}

proc move_fish {instruction} {
    global grid fish

    if {$instruction in "< >"} {
        move_fish_h $instruction
    } elseif {$instruction in "^ v"} {
        move_fish_v $instruction
    }

    # print_grid $grid

}


# GPS needs work...re-read the instructions
proc gps {grid} {
    set gps 0
    foreach box [lsearch_grid $grid {[}] {
        lassign $box row col
        incr gps [expr {100 * $row}]
        incr gps $col
    }
    return $gps
}

proc a {} {move_fish <; p} 
proc s {} {move_fish v; p} 
proc d {} {move_fish >; p} 
proc w {} {move_fish ^; p} 
proc p {} {print_grid $::grid}

foreach instruction $instructions {
    # after 100
    # puts "$instruction"
    move_fish $instruction
}
print_grid $grid
set gps [gps $grid]
puts "Part2 answer = $gps"

