# Optimization using backwards technique here:
#   https://www.reddit.com/r/adventofcode/comments/1h8l3z5/comment/m0ts6o2/
#  - if the target number is not divisible by the last number, then the last operator cannot be *
#  - if the target numbers final digits do not match the last number, then the last operator cannot be ||

# Advent of Code 2024.  
# Day 07: Bridge Repair
# Part 2:  How many lines can expressed as a sum/product/concatention of the items

# Recursive proc.  
proc can_make {result remaining_numbers} {

    # Condition to escape recursion:
    if {[llength $remaining_numbers] == 1} {
        return [expr {$result == $remaining_numbers}]
    } 

    # Consider what can be done with the last number
    set last [lindex $remaining_numbers end]

    # Can the final operator be multiply?
    if {$result % $last == 0} {
        set new_result    [expr {$result / $last}]
        set new_remaining [lrange $remaining_numbers 0 end-1]
        set possible_mul  [can_make $new_result $new_remaining]
    } else {
        set possible_mul 0
    }

    # Can the final operator be concat?
    if {[string match *$last $result] && [string length $result] > [string length $last]} {
        set new_result      [string range $result 0 end-[string length $last]]
        set new_remaining   [lrange $remaining_numbers 0 end-1]
        set possible_concat [can_make $new_result $new_remaining]
    } else {
        set possible_concat 0
    }

    # Can the final operator be addition?
    if {$result >= $last} {
        set new_result    [expr {$result - $last}]
        set new_remaining [lrange $remaining_numbers 0 end-1]
        set possible_add [can_make $new_result $new_remaining]
    } else {
        set possible_add 0
    }

    return [expr {$possible_concat || $possible_mul || $possible_add}]
}
    


proc calibrate_line {line} {
    # Each line is like this:
    # 168135: 205 820 27 4 4
    #   - the number before the colon is the target
    #   - the first number is the start of the running total
    
    lassign [split $line ":"] target numbers

    set status [can_make $target $numbers]
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
        incr sum [calibrate_line $line]
    }
    puts "Sum = $sum"
}

part2 input.txt 
