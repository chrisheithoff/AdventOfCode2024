# Advent of Code 2024.
# Day 12: Garden groups
# Part 1: Get the total price of fencing for all garden groups.
#    The price = area * perimeter

package require math::complexnumbers
namespace import math::complexnumbers::*

source ../aoc_library.tcl

# set data  [exec cat demo.txt]
set data  [exec cat input.txt]
set lines [split $data "\n"]
set grid  [lreverse [make_grid_from_lines $lines]]


# Prepare the data into a dictionary:
#   key = plant type
#   value = list of all locations of the plant
set plants [dict create]
foreach {r row} [enumerate $grid] {
    foreach {c char} [enumerate $row] {
        dict lappend plants $char [list $c $r]
    }
}

# set colors {
#     A red
#     B orange 
#     C yellow 
#     D blue 
#     E purple
#     F green
#     G light_red 
#     H light_orange
#     I light_green
#     J red
#     K orange 
#     L yellow 
#     M blue 
#     N purple
#     O green
#     P light_red 
#     Q light_orange
#     R light_green
#     S red
#     T orange 
#     U yellow 
#     V blue 
#     W purple
#     X green
#     Y light_red 
#     Z light_orange
# }

proc make_geo_mask {origins} {
     set geo_mask [create_geo_mask]
     foreach origin $origins {
         lassign $origin x y
         set bbox [list [list $x $y] [list [incr x] [incr y]]]
         set poly_rect [create_poly_rect -boundary $bbox]
         set geo_mask  [compute_polygons -objects1 $geo_mask -operation OR -objects2 $poly_rect]
     }
     return $geo_mask
}


# The perimeter needs to account for a donut situation
# In the picture below, A 
#    AAA
#    ABA 
#    AAA
# The poly_rect for that geo_mask has a point list which 
#  will include the cut from the outside to the inside.
#  The length of the point_list will exceed the fence length
#  by 2.   
# If any segment is part of the point list path twice, then
# it should not be part of the fence.
proc get_perimeter {poly_rect} {
    set segments [dict create]
    set perimeter 0

    set points [get_attribute $poly_rect point_list]
    
    lappend points [lindex $points 0]

    # Get each unit segment along the point_list path.
    #  - If any segment is included twice, then it will 
    #    not have a fence.  It's in the point_list because
    #    it's a cut from the an outside perimeter to
    #    an inside perimeter.
    foreach p1 [lrange $points 1 end] p2 [lrange $points 0 end-1] {
        foreach segment [get_unit_segments $p1 $p2] {
            if {![dict exists $segments $segment]} {
                incr perimeter
                dict set segments $segment 1
            } else {
                incr perimeter -1
            }
        }
    }
    return $perimeter
}

proc get_unit_segments {p1 p2} {
    set delta [- $p2 $p1]
    set count [expr int([mod $delta])]
    if {[real $delta] > 0} {
        set dir {1 0}
        set p $p1
    } elseif {[real $delta] < 0} {
        set dir {1 0}
        set p $p2
    } elseif {[imag $delta] > 0} {
        set dir {0 1}
        set p $p1
    } elseif {[imag $delta] < 0} {
        set dir {0 1}
        set p $p2
    }
    # Force integer format
    set p_start [format "%.0f %.0f" {*}$p]
    set segments [list]
    while {$count > 0} {
        set p_next [+ $p_start $dir]
        lappend segments [join [concat $p_start $p_next] ":"]
        set p_start $p_next
        incr count -1
    }
    return $segments
}


proc price_check {geo_mask} {
    set price 0
    set poly_rects [get_attribute $geo_mask poly_rects]
    foreach_in_collection poly_rect $poly_rects {
        set area      [expr {int([get_attribute $poly_rect area])}]
        set perimeter [get_perimeter $poly_rect]
        incr price    [expr {$area * $perimeter}]
        # puts "$price"
    }    
    return $price
}

set part1_answer 0
set plant_types [lsort [dict keys $plants]]
foreach plant_type $plant_types {
    set origins [dict get $plants $plant_type]
    puts "$plant_type"
    set geo_mask [make_geo_mask $origins]

    # Color the geo_mask
    [dict get $colors $plant_type] $geo_mask

    set price [price_check $geo_mask]

    incr part1_answer $price
    puts "   $price += $part1_answer"
}
