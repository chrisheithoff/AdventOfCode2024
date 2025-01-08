# Advent of Code 2024.  
# Day 09: Disk Fragmenter
# Part 1:  Move blocks to empty space


source ../aoc_library.tcl


# set data [exec cat demo.txt]
set data  [exec cat input.txt]

# Decode the data into a list of files on the disk
#   - the first,third,fifth,etc number is a file size
#   - the second,fourth,sixth,etc number is an empty block size
proc decode {data} {
    set disk [list]
    set file_id 0

    foreach {file_size blank_size} [split $data ""] {
        lappend disk {*}[lrepeat $file_size $file_id]
        if {$blank_size != ""} {
            lappend disk {*}[lrepeat $blank_size "."]
        }
        incr file_id
    }                   

    return $disk
}

proc defrag {disk} {
    set next_blank 0

    while {1} {
        # Find the next blank "." (starting with the previous blank)
        set next_blank [lsearch -start $next_blank+1 $disk "."]
        if {$next_blank == -1} {
            # no more blanks. They've all been popped off or replaced with files.
            break
        }
        # Pop off the last item (repeat until you get an integer
        while {[set last [lpop disk]] == "."} {} 

        lset disk $next_blank $last
    }
    return $disk
}

proc checksum {disk} {
    set sum 0
    foreach {i n} [enumerate $disk] {
        incr sum [expr {$i * $n}]
    }
    return $sum
}

set disk  [decode $data]
set disk  [defrag $disk]
set part1 [checksum $disk]
puts "Part1 = $part1"



