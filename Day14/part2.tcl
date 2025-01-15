# Advent of Code 2024.
# Day 14: Restroom Redoubt
# Part 2: When will the robots arrange themselves into a picture of a Christmas tree?
#     Return the "safety factor" = "#robots in quadrant A" + "# in B" + "# in C" + "# in D"
#    
source ../aoc_library.tcl

# set data  [exec cat demo.txt]
# set width 11
# set height 7

set data  [exec cat input.txt]
set width  101
set height 103
set lines [split $data "\n"]

set robots [list]
foreach line $lines {
    scan $line "p=%d,%d v=%d,%d" x y vx vy
    lappend robots [list $x $y $vx $vy]
}

set x_mid [expr $width / 2]
set y_mid [expr $height / 2]

# Return location of robot after t seconds
proc predict {x y vx vy t} {
    global width height
    
    # Both x and y wrap around.
    set new_x [expr {($x + $vx*$t) % $width}]
    set new_y [expr {($y + $vy*$t) % $height}]
    return [list $new_x $new_y]
}

proc get_quadrant {x y} {
    global x_mid y_mid
    if {$x == $x_mid || $y == $y_mid} {
        return "CENTER"
    }
    set X [expr {$x > $x_mid}]
    set Y [expr {$y > $y_mid}]
    return "$X$Y"
}

proc visualize {t} {
    global width height robots
    set blank_row [lrepeat $width .]
    set grid [lrepeat $height $blank_row]
    foreach robot $robots {
        lassign $robot x y vx vy
        lassign [predict $x $y $vx $vy $t] col row
        lset grid $row $col "*"
    }
    print_grid $grid
}

# There are 500 robots.  There's a Christmas tree when all 500 robots have a 
# unique location. (I got this hint from  https://www.reddit.com/r/adventofcode/comments/1hdvhvu/2024_day_14_solutions/)
set num_unique_locations [dict create]
set t 0
while {$t < 10000} {
    set locations [dict create]
    foreach robot $robots {
        set new_loc [predict {*}$robot $t] 
        dict incr locations $new_loc
    }

    if {[dict size $locations] == [llength $robots]} {
        break
    }

    incr t
}

visualize $t

puts "Part2 answer: $t"


