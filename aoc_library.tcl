package require struct::set
package require struct::list

# Library of procs that are commonly useful in Advent of Code puzzles

proc one {list} {
    return [lindex $list 0]
}

proc file_to_list {file_name} {
    set f    [open $file_name]
    set list [lrange [split [read $f] "\n"] 0 end-1]
    close $f
    return $list
}

proc file_to_list_of_lists {file_name} {
    # Break lists by empty lines
    set f    [open $file_name]
    set list [lrange [split [read $f] "\n"] 0 end-1]
    close $f

    set list_of_lists [list]
    set sub_list [list]

    foreach line $list {
        # Accumulate lines in the sub_list
        if {[string length $line] > 0} {
            lappend sub_list $line
        } elseif {[string length $line] == 0} {
            # unless they are empty, then add the sublist to list of lists
            lappend list_of_lists $sub_list
            set sub_list [list]
        }
    }
    if {[llength $sub_list] > 0} {
        lappend list_of_lists $sub_list
    }

    return $list_of_lists
}


proc range {start stop {step 1}} {
    # Allow arguments to include math operators.
    set start [expr $start]
    set stop  [expr $stop]

    if {$start == $stop} {
        return $start
    }

    set l [list]
    if {$start < $stop} {
        for {set n $start} {$n <= $stop} {incr n $step} {
            lappend l $n
        }
    } else {
        if {$step == 1} {
            set step -1
        }
        for {set n $start} {$n >= $stop} {incr n $step} {
            lappend l $n
        }
    }
    return $l
}

proc combos {args} {
    # If args is a simple list (not a list of lists), then return the simple list
    #  and break the recursion.
    if {[llength $args]<2} {
        return [lindex $args 0]
    }

    set result [list]

    # Iterate the first list in the outer loop and a combo of the rest in the inner loop
    set args [lassign $args first_list]

    # The second loop is the recursive solution for the remaining list in args
    set remaining_combos [combos {*}$args]

    foreach l $first_list {
        foreach combo $remaining_combos {
            lappend result [list $l {*}$combo]
        }
    }
    return $result
}


# From  https://wiki.tcl-lang.org/page/Permutations
#   Return possibilites from list $l, select $k at a time
proc Select {k l} {
    if {$k == 0} {return {}}
    if {$k == [llength $l]} {return [list $l]}

    set all {}
    incr k -1
    for {set i 0} {$i < [llength $l]-$k} {incr i} {
        set first [lindex $l $i]
        if {$k == 0} {
            lappend all $first
        } else {
            foreach s [Select $k [lrange $l [expr {$i+1}] end]] {
                set ans [concat $first $s]
                lappend all $ans
            }
        }
    }
    return $all
}


proc vector_add {args} {
    # Expect a list of vectors all of same length
    set sums_dict [dict create]
    foreach vector $args {
        set i 0
        foreach value $vector {
            dict incr sums_dict $i $value
            incr i
        }
    }
    return [dict values $sums_dict]
}

proc vector_mult {m vector} {
    return [lmap c $vector {expr $m * $c}]
} 

proc plist {list {prefix ""}} {
    foreach l $list {
        puts "$prefix$l"
    }
}

proc pdict {dict} {
    set keys [lsort -dictionary [dict keys $dict]]
    set key_lengths [lmap k $keys {string length $k}]
    set max_key_length [tcl::mathfunc::max {*}$key_lengths]
    foreach key $keys {
        set value [dict get $dict $key]
        puts "[format %-${max_key_length}s $key]   $value"
    }
}

# Grid as list of lists.
proc make_grid_from_lines {lines {map ""}} {
    set grid [list]
    foreach row $lines {
        set row [string map $map $row]
        lappend grid [split $row ""]
    }
    return $grid
}

proc print_grid {grid} {
    foreach row $grid {
        puts [join $row ""]
    }
}

# Return the indexes that equal match.
proc lsearch_grid {grid match} {

    set matches [list]
    foreach {r row} [enumerate $grid] {
        foreach {c char} [enumerate $row] {
            if {$char == $match} {
                lappend matches [list $r $c]
            }
        }
    }
    return $matches
}

# Rotate and flip grids
proc flip_left {grid} {
    set flipped_grid [list]
    foreach row $grid {
        lappend flipped_grid [lreverse $row]
    }
    return $flipped_grid
}

proc flip_top {grid} {
    return [lreverse $grid]
}

proc rotate_left {grid} {
    set rotated_grid  [list]
    set num_columns   [llength [lindex $grid 0]]
    set max_col_index [expr {$num_columns-1}]
    for {set j $max_col_index} {$j >= 0} {incr j -1} {
        set column_j [lmap g $grid {lindex $g $j}]
        lappend rotated_grid $column_j
    }
    return $rotated_grid
}

proc rotate_right {grid} {
    set rotated_grid  [list]
    set num_columns   [llength [lindex $grid 0]]
    for {set j 0} {$j < $num_columns} {incr j} {
        set column_j [lmap g $grid {lindex $g $j}]
        lappend rotated_grid [lreverse $column_j]
    }
    return $rotated_grid
}

proc rotate_180 {grid} {
    set rotated_grid  [list]
    foreach row [lreverse $grid] {
        lappend rotated_grid [lreverse $row]
    }
    return $rotated_grid
}

proc get_grid_col {grid j} {
    return [lmap g $grid {lindex $g $j}]
}

proc get_grid_row {grid i} {
    return [lindex $grid $i]
}

proc locate_edge {grid edge} {
    set reversed [lreverse $edge]
    # Return a value 1 (left), 2 (top), 3 (right), 4 (bottom).  
    #    Negative if the edge is reversed
    #    Or 0 for not found.
    #
    set top   [lindex $grid 0]
    if {$edge == $top} {
        return 2
    } elseif {$reversed == $top} {
        return -2
    }

    set bot   [lindex $grid end]
    if {$edge == $bot} {
        return 4
    } elseif {$reversed == $bot} {
        return -4
    }

    set left [get_grid_col $grid 0]
    if {$edge == $left} {
        return 1
    } elseif {$reversed == $left} {
        return -1
    }

    set right [get_grid_col $grid end]
    if {$edge == $right} {
        return 3
    } elseif {$reversed == $right} {
        return -3
    }

    return 0
}

proc orient_grid {grid edge edge_num} {
    # Rotate the grid until the given edge matches the desired edge_num
    set l [locate_edge $grid $edge]

    while {abs($l) != $edge_num} {
        set grid [rotate_left $grid]
        set l [locate_edge $grid $edge]
        if {$l == 0} {
            puts "Edge $e not found in grid"
            return
        }
    }

    if {$l != $edge_num} {
        if {$l % 2 == 0} {
            set grid [flip_left $grid]
        } else {
            set grid [flip_top $grid]
        }
    }
    return $grid
}

proc get_subgrid {grid min_row max_row min_col max_col} {
    set subgrid []
    set subrows [lrange $grid $min_row $max_row]
    foreach subrow $subrows {
        lappend subgrid [lrange $subrow $min_col $max_col]
    }
    return $subgrid
}
        
proc sum {args} {
    set sum 0
    # Iterate over each argument
    foreach arg $args {
        # But expand the argument if it's a list.
        incr sum [tcl::mathop::+ {*}$arg]
    }
    return $sum
}

proc bin2dec {bin} {
    return [expr 0b${bin}]
}

proc dec2bin {dec {len ""}} {
    if {$len == ""} {
        return [format %b $dec]
    } else {
        return [format %0${len}b $dec]
    }
}

proc lwhere {varname list condition} {
    uplevel [list lmap $varname $list \
        "if [list $condition] {set [list $varname]} continue"]
}
  
proc lpop listVar {
    upvar 1 $listVar l
    set r [lindex $l end]
    set l [lreplace $l [set l end] end] ; # Make sure [lreplace] operates on unshared object
    return $r
}

proc hex2bin {hex} {
    set map { 
        0 0000 1 0001 2 0010 3 0011
        4 0100 5 0101 6 0110 7 0111
        8 1000 9 1001 A 1010 B 1011
        C 1100 D 1101 E 1110 F 1111
        a 1010 b 1011
        c 1100 d 1101 e 1110 f 1111
    }
    return [string map $map $hex]
}

proc sum_of_n {n} {
    return [expr {$n * ($n+1) / 2}]
}

# From https://rosettacode.org/wiki/Least_common_multiple#Tcl
proc lcm {p q} {
    set m [expr {$p * $q}]
    if {!$m} {return 0}
    while 1 {
        set p [expr {$p % $q}]
        if {!$p} {return [expr {$m / $q}]}
        set q [expr {$q % $p}]
        if {!$q} {return [expr {$m / $p}]}
    }
}

# From   https://wiki.tcl-lang.org/page/Greatest+common+denominator
proc gcd {p q} {
    while 1 {
        if {![set p [expr {$p % $q}]]} {return [expr {$q>0?$q:-$q}]}
        if {![set q [expr {$q % $p}]]} {return [expr {$p>0?$p:-$p}]}
    }
}

proc enumerate {list "i 0"} {
    set result [list]
    foreach l $list {
        lappend result $i $l
        incr i
    }
    return $result
}

