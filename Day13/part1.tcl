# Advent of Code 2024.
# Day 13: Claw Contraption
# Part 1: How many times tokens must you spend to get all possible prizes?
#    

package require math::complexnumbers
namespace import math::complexnumbers::*

source ../aoc_library.tcl

# set data  [exec cat demo.txt]
set data  [exec cat input.txt]
set lines [split $data "\n"]

# Parse lines to get claw games
set claws [list]
foreach {lineA lineB lineC blank} $lines {
    lassign [regexp -inline -all {\d+} $lineA] ax ay
    lassign [regexp -inline -all {\d+} $lineB] bx by
    lassign [regexp -inline -all {\d+} $lineC] X  Y
    lappend claws [list $ax $ay $bx $by $X $Y]
}

# Given the system of equations:
#   X = ax*A + bx*B
#   Y = ay*A + by*B
#   Cost = 3A + B
# 1) solve for B = (X*ay - Y*ax) / (bx*ay - by*ax)
# 2) then solve for A = (X - bx*B) / ax
# 3) compute cost
#
# A and B MUST be integers.  Check for divisibility first.
# Otherwise, return 0.

proc play_game {claw} {
    lassign $claw ax ay bx by X Y

    set B_num [expr {$X * $ay - $Y * $ax}]
    set B_den [expr {$bx * $ay - $by * $ax}]
    if {$B_num % $B_den == 0} {
        set B [expr {$B_num / $B_den}]
    } else {
        return 0
    }

    set A_num [expr {$X - $bx * $B}]
    set A_den $ax
    if {$A_num % $A_den == 0} {
        set A [expr {$A_num / $A_den}]
    } else {
        return 0
    }

    return [expr {3*$A + $B}]
}

set cost 0
foreach claw $claws {
    set tokens [play_game $claw]
    incr cost $tokens
}

puts "Part1 answer = $cost"
