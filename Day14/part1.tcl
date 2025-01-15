# Advent of Code 2024.
# Day 14: Restroom Redoubt
# Part 1:  Predict robot locations after 100 seconds.
#     Return the "safety factor" = "#robots in quadrant A" + "# in B" + "# in C" + "# in D"
#    

# set data  [exec cat demo.txt]
# set width 11
# set height 7

set data  [exec cat input.txt]
set width  101
set height 103
set lines [split $data "\n"]

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

set quadrants [dict create]
foreach line $lines {
    scan $line "p=%d,%d v=%d,%d" x y vx vy
    set new_loc  [predict $x $y $vx $vy 100]
    set quadrant [get_quadrant {*}$new_loc]
    if {$quadrant != "CENTER"} {
        dict incr quadrants $quadrant 
    }
}

set score [tcl::mathop::* {*}[dict values $quadrants]]
puts "Part1 answer = $score"

