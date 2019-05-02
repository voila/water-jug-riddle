/* Impose an ordering on the State. */
open util/ordering[State]
open util/integer

/* Stores the jugs level */
sig State { small, big:Int }

/* initial state */
fact { first.small = 0 && first.big = 0 }

pred emptyBig(s, s': State) {
    s'.big = 0
    s'.small = s.small
}

pred emptySmall(s, s': State) {
       s'.big = s.big
    s'.small = 0
}

pred fillBig(s, s': State) {
    s'.big = 5
    s'.small = s.small
}

pred fillSmall(s, s': State) {
       s'.big = s.big
    s'.small = 3
}

pred smallToBig(s, s': State) {
    s'.big = smaller [plus [s.big, s.small], 5]
    s'.small =  larger [minus [plus [s.small, s.big], 5] , 0] 
}

pred bigToSmall(s, s': State) {
       s'.big = larger [minus [plus [s.big,  s.small], 3], 0]
    s'.small = smaller [plus [s.small, s.big] , 3]
}


fact {
  all s: State - last, s': s.next {
        bigToSmall [s, s'] or smallToBig [s, s'] or
        fillBig [s, s'] or 
        fillSmall [s, s'] or
        emptyBig [s, s'] or emptySmall [s, s'] 
   }
}

check { last.big != 4 } for 7 State

