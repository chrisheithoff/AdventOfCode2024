# Advent of Code 2024.  
# Day 02:  Red-Nosed Reports
# Part 2:  Problem Dampener.  One bad step is allowed, but no more.


set data [exec cat input.txt]
# set data [exec cat demo.txt]
set reports [split $data "\n"]

proc is_report_safe {report} {

    # Make two lists for iterating together
    set list1 [lrange $report 0 end-1]
    set list2 [lrange $report 1 end]

    # Make list of all the step sizes
    set steps [list]
    foreach a $list1 b $list2 {
        set step [expr {$b - $a}]
        lappend steps $step
    }
    set steps [lsort -integer $steps]
    
    set min [lindex $steps 0]
    set max [lindex $steps end]

    # Safe if all positive steps and between the limits
    if {$min>=1 && $max<=3} {
        return 1
    } elseif {$min>=-3 && $max<=-1} {
        return 1
    } else {
        return 0
    }
}

set num_safe_reports 0
foreach report $reports {
    set is_safe [is_report_safe $report]

    # Try dropping any of the elements in the list and re-checking.
    if {$is_safe==0} {
        for {set i 0} {$i < [llength $report]} {incr i} {
            set report_with_drop [lreplace $report $i $i]
            if {[is_report_safe $report_with_drop]} {
                set is_safe 1
                break
            }
        }
    }

    puts "$report: $is_safe"
    incr num_safe_reports $is_safe
}

puts "Part2 answer: $num_safe_reports safe reports"

