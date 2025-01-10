# Advent of Code 2024.  
# Day 11: Plutonian Pebbles
# Part 2: Same as part1, but now "75" times


# In part2, 75 blinks will take way too long for doing one stone at a time.
# Use a dict:
#    key = number written on stone
#    value = total number of stones with that value
# The stones do not need to be in a certain order, so a list is unnecessary.
# All stones with the same number can be processed at the same.
# 
proc blink {stones} {
    dict for {stone count} $stones {
        # Remove the old stones from the inventory.
        if {[dict get $stones $stone] == $count} {
            dict unset stones $stone
        } else {
            dict incr stones $stone -$count
        }

        # Add new stones to the inventory.
        if {$stone == 0} {
            # 1)  If a stone is zero, replace with a one
            dict incr stones 1 $count
        } elseif {[string length $stone] % 2 == 0} {
            # 2)  If a stone has an even # of digits, replace with two stones with the left and right halves
            set half_len     [expr {[string length $stone] / 2}]
            set first_stone  [string range $stone 0 $half_len-1]
            set second_stone [string trimleft [string range $stone $half_len end] "0"]
            if {$second_stone == ""} {
                set second_stone 0
            }
            
            dict incr stones $first_stone  $count
            dict incr stones $second_stone $count
        } else {
            # 3)  Otherwise multiply by 2024.
            dict incr stones [expr {$stone * 2024}] $count
        }
    }
    return $stones
}

proc count_stones {stones} {
    set sum 0
    foreach value [dict values $stones] {
        incr sum $value
    }
    return $sum
}

# set data "125 17"
set data  [exec cat input.txt]

set stones [dict create]
foreach d $data { 
    dict incr stones $d 1
}

set num_blinks 250

for {set i 0} {$i < $num_blinks} {incr i} {
    set stones [blink $stones]
}

puts "Part2 answer: [count_stones $stones]"

