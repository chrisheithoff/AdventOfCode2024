# Advent of Code 2024.  
# Day 04: Mull It Over
# Part 1: Ceres Search

source ../aoc_library.tcl

# set data [exec cat demo.txt]
set data [exec cat input.txt]

set lines [split $data "\n"]

# Convert to 2-D grid
set grid [make_grid_from_lines $lines]

# Possible directions:
set dirs [list {0 1} {0 -1} {1 0} {-1 0} {1 1} {1 -1} {-1 1} {-1 -1}]

# Find a four-letter word in given direction
proc find_word {grid i j dir} {
     set word [lindex $grid $i $j]
     foreach d [lrepeat 3 $dir] {
         incr i [lindex $dir 0]
         incr j [lindex $dir 1]
         set new_letter [lindex $grid $i $j]
         append word $new_letter
     }
     return $word
}


# Brute force.
#    - locate each X in the grid.
#    - for each X, check the three neighbors for M-A-S
set count 0
foreach {i row} [enumerate $grid] {
    foreach {j letter} [enumerate $row] {
        if {$letter == "X"} {
            foreach dir $dirs {
                set word [find_word $grid $i $j $dir]
                if {$word == "XMAS"} {
                    incr count
                    puts "$count: $word ($i, $j, $dir)"
                }
            }
        }
    }
}

puts "Part1 answer: $count"

