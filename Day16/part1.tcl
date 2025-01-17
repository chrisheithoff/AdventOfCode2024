# Advent of Code 2024.  
# Day 16: Reindeer Maze
# Part 1: Find path through maze with lowest score

package require math::complexnumbers
namespace import math::complexnumbers::*
source ../aoc_library.tcl

# Path Finding:  Use Dijkstra's Theorem (actually the A* variation)
#   - keep track of things using a table, implemented as two dictionaries.
#   - use state instead of location because we need to account for rotation
#
#  Initialize: Start at bottom left facing east.
#  state          
#  loc/dir        score   from       
#  {1 1} {0 1}     0       "start"   
#
#  Step 1:  Mark the current state as visited.
#  loc/dir        score   from      visited
#  {1 1} {0 1}     0       "start"   1
#
#  Step 2: Get the next possible states.  
#        - move one step forward or turn 90 deg
#        - don't repeat a state
#        - not a wall
#  {1 2} {0 1}
#  {1 1} {1 0}
#  
#  Step 3: Record the score for each next possible state
#      +1    for a step forward
#      +1000 for a rotation
#  state          score   from          visited
#  {1 1} {0 1}    0       "start"       1
#  {1 2} {0 1}    1       {1 1} {0 1}   
#  {1 1} {1 0}    1000    {1 1} {0 1}
#
#  Step 4: Add the new states to a priority queue, "unvisited"
#     (implemented as a list of 2-item lists)
#    Each state is sorted by score, from low to high.
#
#  Step 5: Pop the first state off the priority queue.
#
#  Go back to step 1.  Repeat until you're at the "E" character.
#
proc get_next_states {state} {
    set next_states [list]
    lassign $state loc dir

    # One step forward
    lappend next_states [list [+ $loc $dir] $dir]

    # Rotate left or right
    lappend next_states [list $loc [* $dir [list 0 1]]]
    lappend next_states [list $loc [* $dir [list 0 -1]]]

    return $next_states
}

set scores    [dict create]
set from      [dict create]
set visited   [dict create]
set unvisited [list] 

# set data  [exec cat demo2.txt]
set data  [exec cat input.txt]
set lines [split $data "\n"]
set grid [make_grid_from_lines $lines]

# Starting conditions:  facing "east".
set start_loc [lindex [lsearch_grid $grid "S"] 0]
set start_dir [list 0 1]
set start_state [list $start_loc $start_dir]
dict set scores $start_state 0


set state $start_state
while {1} {
    set score [dict get $scores $state]
    # puts "Visiting {$state} ($score)"
    
    # 1)  Mark state as visited
    dict set visited $state 1

    # Are we there yet?
    lassign $state loc dir 
    if {[lindex $grid {*}$loc] == "E"} {
        break
    }

    # Step 2: Get the possible next states.
    set next_states     [get_next_states $state]

    # Step 3: Update the tables for the next states.
    foreach next_state $next_states {
        # Skip if already visited that exact state.
        if {[dict exists $visited $next_state]} {
            continue
        }

        # Skip if "#"
        lassign $next_state next_loc next_dir
        if {[lindex $grid {*}$next_loc] == "#"} {
            continue
        }
        
        # Figure out the total heat loss if we were to visit this state.
        if {$next_dir == $dir} {
            set next_score [expr {$score + 1}]
        } else {
            set next_score [expr {$score + 1000}]
        }

        # Add a new state to the tables (or replace with a better value)
        if {![dict exists $scores $next_state]} {
            dict set scores $next_state $next_score
            dict set from   $next_state $state
        } elseif {$next_score < [dict get $scores $state]} {
            dict set scores $next_state $next_score
            dict set from   $next_state $state
        } else {
            continue
        }

        # Add the next_state to the unvisited priority queue according to its score
        #   - use "lsearch -bisect"
        set insertion_spot [expr {[lsearch -index 1 -bisect -integer $unvisited $score]+1}]
        set unvisited      [linsert $unvisited $insertion_spot [list $next_state $score]]
    }

    # Step 5: Choose the first value in the sorted priority queue
    set unvisited [lassign $unvisited first]
    set state     [lindex $first 0]
}

set part1_answer $score

# Just for fun, visualize the finished path.
set finished_grid $grid
while {1} {
    set prev_state [dict get $from $state]
    lassign $prev_state prev_loc prev_dir
    puts $prev_loc
    if {$prev_loc == $start_loc} {
        break
    }
    if {$prev_dir == [list 0 1]} {
        set prev_char >
    } elseif {$prev_dir == [list 0 -1]} {
        set prev_char <
    } elseif {$prev_dir == [list 1 0]} {
        set prev_char v
    } elseif {$prev_dir == [list -1 0]} {
        set prev_char ^
    }
    lset finished_grid {*}$prev_loc $prev_char
    set state $prev_state
}
print_grid $finished_grid
puts "Part1_answer = $part1_answer"




