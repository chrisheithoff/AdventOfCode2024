# Advent of Code 2024.
# Day 12: Garden groups
# Part 1: Get the total price of fencing for all garden groups.
#    The price = area * perimeter

package require math::complexnumbers
namespace import math::complexnumbers::*

source ../aoc_library.tcl

# set data  [exec cat demo2.txt]
set data  [exec cat input.txt]
set lines [lreverse [split $data "\n"]]

# Prepare the data into a dictionary:
#   key = plant type
#   value = list of all locations of the plant
set plants [dict create]
foreach {r row} [enumerate $lines] {
    foreach {c char} [enumerate [split $row ""]] {
        dict lappend plants $char [list $c $r]
    }
}

# Create a geo_mask as the union of all unit squares of a plant type.
proc make_geo_mask {origins} {
     set bboxes   [list]
     foreach origin $origins {
         lassign $origin x y
         set bbox [list [list $x $y] [list [incr x] [incr y]]]
         lappend bboxes $bbox
     }
     set poly_rects [create_poly_rect -boundary $bboxes]
     set geo_mask   [create_geo_mask  -objects $poly_rects -merge]
     return $geo_mask
}

# Return a poly_rects collection of a poly_rects holes
proc get_holes {poly_rect} {
    set background [create_poly_rect -boundary [list {-1 -1} {141 141}]]
    set area  [get_attribute $poly_rect area]
    set not   [compute_polygons -objects1 $background -operation NOT -objects2 $poly_rect]
    set holes [filter_collection [get_attribute $not poly_rects] "area < $area"]
}

proc get_perimeter_of_point_list {points} {
    set perimeter 0
    set num_points [llength $points]
    lappend points [lindex $points 0]

    for {set i 0} {$i < $num_points} {incr i} {
        set p1 [lindex $points $i]
        set p2 [lindex $points $i+1]
        incr perimeter [expr {int([mod [- $p2 $p1]])}]
    }
    return $perimeter
}

# The perimeter needs to account for holes.  
#  - The point_list of a poly_rect will include a cut from the outside perimeter
#    to the hole.
proc get_perimeter_of_poly_rect {poly_rect} {
    set perimeter 0

    # Get perimeter of any holes
    set holes [get_holes $poly_rect]
    foreach_in_collection hole $holes {
        set hole_points [get_attribute $hole point_list]
        incr perimeter [get_perimeter_of_point_list $hole_points]
    }

    # Get perimeter of new poly_rect with holes filled in
    if {$holes != ""} {
        set filled_in [compute_polygons -objects1 $poly_rect -operation OR -objects2 $holes]
        set outside_points [get_attribute $filled_in poly_rects.point_list]
    } else {
        set outside_points [get_attribute $poly_rect point_list]
    }

    incr perimeter [get_perimeter_of_point_list $outside_points]
    
    return $perimeter
}


proc price_check {geo_mask} {
    set price 0
    set poly_rects [get_attribute $geo_mask poly_rects]
    foreach_in_collection poly_rect $poly_rects {
        set area      [expr {int([get_attribute $poly_rect area])}]
        set perimeter [get_perimeter_of_poly_rect $poly_rect]
        incr price    [expr {$area * $perimeter}]
        # puts "    Area ($area) * Perimeter ($perimeter) += $price"
    }    
    return $price
}

set part1_answer 0
set plant_types [lsort [dict keys $plants]]
foreach plant_type $plant_types {
    set origins [dict get $plants $plant_type]
    puts "$plant_type"
    set geo_mask [make_geo_mask $origins]

    red $geo_mask

    set price [price_check $geo_mask]

    incr part1_answer $price
    puts "   $price += $part1_answer"
}
