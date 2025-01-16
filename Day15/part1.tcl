# Advent of Code 2024.
# Day 15: Warehouse Woes
# Part 1: Move boxes around and measure the GPS.
    
package require math::complexnumbers
namespace import math::complexnumbers::*

source ../aoc_library.tcl

# set data  [exec cat demo.txt]
set data  [exec cat input.txt]
set lines [split $data "\n"]
set blank_line [lsearch $lines ""]

set grid [make_grid_from_lines [lrange $lines 0 $blank_line-1]]
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


proc move_fish {instruction} {
    global grid fish

    set dir [get_dir $instruction]
    
    # Search in the direction until an empty space or # is found
    set loc $fish
    set locs  [list $loc]
    set chars [list "." "@"]
    
    while {1} {
        set loc  [+ $loc $dir]
        set char [lindex $grid {*}$loc]

        if {$char == "#"} {
            return
        } elseif {$char == "O"} {
            lappend locs $loc
            lappend chars $char
        } elseif {$char == "."} {
            lappend locs $loc
            break
        }
    }

    # Move fish and boxes
    set fish [lindex $locs 1]
    foreach new_loc $locs new_char $chars {
        lset grid {*}$new_loc $new_char
    }

}

proc gps {grid} {
    set gps 0
    foreach box [lsearch_grid $grid "O"] {
        lassign $box row col
        incr gps [expr {100*$row}]
        incr gps $col
    }
    return $gps
}

foreach instruction $instructions {
    move_fish $instruction
}
print_grid $grid
set gps [gps $grid]
puts "Part1 answer = $gps"

