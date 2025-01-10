# Advent of Code 2024.  
# Day 11: Plutonian Pebbles
# Part 1: How many stones are there after blinking 25 times?


# set data "125 17"
set data  [exec cat input.txt]

# Rules foreach stone with each blink
#    1)  If a stone is zero, replace with a one
#    2)  If a stone has an even # of digits, replace with two stones with the left and right halves
#    3)  Otherwise multiply by 2024.

proc blink {stones} {
    set new_stones [list]
    foreach stone $stones {
        # puts "{$stone} $stones"
        if {$stone == 0} {
            lappend new_stones 1
        } elseif {[string length $stone] % 2 == 0} {
            set half_len [expr {[string length $stone] / 2}]
            lappend new_stones [string range $stone 0 $half_len-1]
            set new_stone [string trimleft [string range $stone $half_len end] "0"]
            if {$new_stone == ""} {
                lappend new_stones 0
            } else {
                lappend new_stones $new_stone
            }
        } else {
            lappend new_stones [expr {$stone * 2024}]
        }
    }
    set stones $new_stones
    return $stones
}


set stones $data
set num_blinks 25
for {set i 0} {$i < $num_blinks} {incr i} {
    set stones [blink $stones]
}

puts "Part1 answer: [llength $stones]"

