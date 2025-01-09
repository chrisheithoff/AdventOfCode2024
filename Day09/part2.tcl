# Advent of Code 2024.  
# Day 09: Disk Fragmenter
# Part 2:  Move blocks to empty space (but only if there's enough room)


source ../aoc_library.tcl

# The data structures explained:
#  addresses (dict)     :  Address for a given file_id
#  sizes (dict)         :  Size of a given file_id
#  free (list of lists) :  Free blocks in order.  Each sublist is {address size}

proc part2 {input_file} {
    global addresses sizes free 
    set data  [exec cat $input_file]

    # Initialize 
    set addresses      [dict create]
    set sizes          [dict create]
    set free           [list]
    set pointer 0
    set file_id -1

    # Convert the input data to disk information (add final zero for an even number)
    set data_to_list [split $data ""]
    lappend data_to_list 0
    foreach {file_size blank_size} $data_to_list {

        # Save this file's address and sizes
        incr file_id
        dict set addresses $file_id $pointer
        dict set sizes     $file_id $file_size
        incr pointer $file_size

        # Save info about free blocks.  Skip 0-sized free space.
        if {$blank_size != "0"} {
            lappend free [list $pointer $blank_size]
            incr pointer $blank_size
        }
    }                   

    # Defrag each file id, from greatest to lowest id value.
    while {$file_id >= 0} {
        defrag $file_id
        incr file_id -1
    }

    puts "Part2 = [checksum $addresses $sizes]"
}

proc defrag {file_id} {
    global addresses sizes free

    set file_size    [dict get $sizes     $file_id]
    set file_address [dict get $addresses $file_id]
    set num_free     [llength $free]

    # Check for free space to move the file
    for {set i 0} {$i < $num_free} {incr i} {
        set address [lindex $free $i 0]
        set size    [lindex $free $i 1]

        # Only move the file to the left.
        if {$address >= $file_address} {
            break
        }

        # Is there enough free space?
        if {$size >= $file_size} {
            # Move file to new address
            dict set addresses $file_id $address

            # Update free space info.
            #   - if no leftover free space, remove from the list
            #   - otherwise, redefine the list with the new address and size
            if {$size == $file_size} {
                set free [lreplace $free $i $i]
            } else {
                lset free $i 0 [incr address $file_size]
                lset free $i 1 [incr size   -$file_size]
            }

            break
        }
    }

    return
}

proc checksum {addresses sizes} {
    set sum 0

    dict for {file_id start_address} $addresses {
        set file_size   [dict get $sizes $file_id]
        set end_address [expr {$start_address + $file_size}]
        for {set address $start_address} {$address - $start_address < $file_size} {incr address} {
            incr sum [expr {$address * $file_id}]
        }
    }

    return $sum

}

# part2 demo.txt
time {part2 input.txt} 10




