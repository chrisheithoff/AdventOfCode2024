# Advent of Code 2024.  
# Day 07: Bridge Repair
# Part 2:  How many lines can expressed as a sum/product/concatention of the items

namespace import tcl::mathop::*

# New proc for concatenation.
proc || {a b} {
    string cat $a $b 
}

# Recursive proc.  
proc calibrate {target running_total remaining_numbers} {
#   - 1) Escape regression if there are no more remaining numbers (the only way to return 1)
    if {[llength $remaining_numbers] == 0} {
        return [expr {$target == $running_total}]
    } 

    # 2) If there are remaining numbers, then enter one step of recursion
    set status 0
    set new_remaining_numbers [lassign $remaining_numbers next_number]

    # Check concatenation, multiplication and addition.  
    #   - if ALL exceed target, then we're done (return 0)
    #   - test concatenation and multiplication before addition to more quickly eliminate unneeded recursions 
    foreach op {|| * +} {
        set new_running_total [$op $running_total $next_number]

        if {$new_running_total > $target} {
            continue
        } else {
             set status [calibrate $target $new_running_total $new_remaining_numbers]
             if {$status == 1} {
                 break
             }
        }
    }
    return $status
}



proc calibrate_line {line} {
    # Each line is like this:
    # 168135: 205 820 27 4 4
    #   - the number before the colon is the target
    #   - the first number is the start of the running total
    
    lassign [split $line ":"] target numbers
    set remaining_numbers [lassign $numbers first_number]
    set status [calibrate $target $first_number $remaining_numbers]
    if {$status} {
        return $target
    } else {
        return 0
    }
}

proc part2 {file_name} {
    set data [exec cat $file_name]

    set lines [split $data "\n"]

    set sum 0
    foreach line $lines {
        puts [time {incr sum [calibrate_line $line]}]
    }
    puts "Sum = $sum"
}

part2 input.txt 