# Advent of Code 2024.  
# Day 03: Mull It Over
# Part 2:  do () and don't()

# set data [exec cat demo2.txt]
set data [exec cat input.txt]

set cmds [regexp -all -inline {(?:mul|do|don't)\(\d*,?\d*\)} $data]

set answer 0
set do 1
foreach cmd $cmds {
    puts $cmd
    lassign [split $cmd "()"] cmd_name args
    if {$cmd_name == "do"} {
        set do 1
    } elseif {$cmd_name == "don't"} {
        set do 0
    } elseif {$cmd_name == "mul"} {
        if {$do} {
            lassign [split $args ","] a b
            incr answer [expr {$a * $b}]
            puts "do it:  $a * $b  (answer = $answer)"
        }
    }

}

puts "Part2 answer: $answer"

