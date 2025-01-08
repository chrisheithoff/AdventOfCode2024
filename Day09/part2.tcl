# Advent of Code 2024.  
# Day 09: Disk Fragmenter
# Part 2:  Move blocks to empty space (but only if there's enough room)


source ../aoc_library.tcl

# Data structures explained:
#  addresses (dict)  :  Return address for a given file_id
#  sizes (dict)      :  Return size for a given file_id
#  free_sizes (dict) :  Return size for a free block starting at given address
#  free_addresses (list):  Sorted list of free blocks starting addresses.


proc part2 {input_file} {
    global addresses sizes free_sizes free_addresses
    set data  [exec cat $input_file]

    # Initialize 
    set addresses      [dict create]
    set sizes          [dict create]
    set free_sizes     [dict create]
    set free_addresses [list]
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
            dict set free_sizes $pointer $blank_size
            lappend free_addresses $pointer
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
    global addresses sizes free_sizes free_addresses

    set file_size    [dict get $sizes $file_id]
    set file_address [dict get $addresses $file_id]
    set num_free     [llength $free_addresses]

    # Find the first free space to the left of the file with enough room for it.
    for {set i 0} {$i < $num_free} {incr i} {

        set free_address [lindex $free_addresses $i]
        if {$free_address >= $file_address} {
            break
        }
        set free_size [dict get $free_sizes $free_address]

        if {$free_size >= $file_size} {
            # Move file to new address
            dict set addresses $file_id $free_address

            # Update free space info.
            #   - if no leftover free space, remove from both the dict and the list
            #   - otherwise, redefine the dict and the list with the leftover
            if {$free_size == $file_size} {
                dict unset free_sizes $free_address
                set free_addresses [lreplace $free_addresses $i $i]
            } else {
                dict unset free_sizes $free_address
                dict set free_sizes [incr free_address $file_size] [incr free_size -$file_size]
                set free_addresses [lreplace $free_addresses $i $i $free_address]
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
part2 input.txt




