# Advent of Code 2024.  
# Day 04: Mull It Over
# Part 2: X-MAS puzzle

source ../aoc_library.tcl

# set data [exec cat demo.txt]
set data [exec cat input.txt]

set lines [split $data "\n"]

# Convert to 2-D grid
set grid [make_grid_from_lines $lines]

# Find two MAS X-ing each other.
proc is_x_mas {grid i j} {
    # Center should be A
    if {[lindex $grid $i $j] != "A"} {
        return 0
    }

    # Get the four corners
    set corners ""
    append corners [lindex $grid $i-1 $j-1]
    append corners [lindex $grid $i-1 $j+1]
    append corners [lindex $grid $i+1 $j-1]
    append corners [lindex $grid $i+1 $j+1]

    if {$corners in {MMSS MSMS SSMM SMSM}} {
        return 1
    } else {
        return 0
    }
}


set count 0
foreach {i row} [enumerate $grid] {
    foreach {j letter} [enumerate $row] {
        set result [is_x_mas $grid $i $j]
        if {$result} {
            incr count $result
        }
    }
}

puts "Part2 answer: $count"
