from z3 import *

Jug, (Big, Small) = EnumSort(
    'Jug', ['Big', 'Small'])
Act, (FillBig, FillSmall, EmptyBig, EmptySmall, BigToSmall, SmallToBig) = EnumSort(
    'Act', ['FillBig', 'FillSmall', 'EmptyBig', 'EmptySmall', 'BigToSmall', 'SmallToBig'])

#m = 10
for n in range(5, 10):
    print("n = {}".format(n))
    # create variables for jugs' volume and actions taken, at each time step
    big = []
    small = []
    actions = []
    for t in range(n):
        big.append(Int('big{}'.format(t)))
        small.append(Int('small{}'.format(t)))
        actions.append(Const('act{}'.format(t), Act))

    s = Solver()

    # empty at t = 0
    s.add(big[0] == 0)
    s.add(small[0] == 0)
    s.add(actions[0] == EmptyBig)

    # 6 constraints, from 6 actions, at each step t < n
    for t in range(1, n):
        s.add(Or(
            actions[t] == BigToSmall,
            actions[t] == SmallToBig,
            actions[t] == FillBig,
            actions[t] == FillSmall,
            actions[t] == EmptyBig,
            actions[t] == EmptySmall))

        s.add(
            Or(
                And(actions[t] == FillBig,
                    big[t] == 5, small[t] == small[t-1]),

                And(actions[t] == FillSmall,
                    small[t] == 3, big[t] == big[t-1]),

                And(actions[t] == EmptyBig,
                    big[t] == 0, small[t] == small[t-1]),

                And(actions[t] == EmptySmall,
                    small[t] == 0, big[t] == big[t-1]),

                And(actions[t] == BigToSmall,
                    If(big[t-1] + small[t-1] > 3,
                       And(small[t] == 3,
                           big[t] == big[t-1] + small[t-1] - 3),
                       And(small[t] == big[t-1] + small[t-1], big[t] == 0))
                    ),

                And(actions[t] == SmallToBig,
                    If(big[t-1] + small[t-1] > 5,
                       And(big[t] == 5, small[t]
                           == big[t-1] + small[t-1] - 5),
                       And(big[t] == big[t-1] + small[t-1], small[t] == 0))
                    )))

    # can we end up with 4 litres in big jug ?
    s.add(big[t] == 4)

    if s.check() == sat:
        print("SAT")
        m = s.model()
        for i in range(n):
            print("{}: {} {}".format(m.evaluate(
                actions[i]), m.evaluate(small[i]), m.evaluate(big[i])))
        exit(0)
    else:
        print("UNSAT")
