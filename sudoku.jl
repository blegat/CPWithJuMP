# Inspired from https://jump.dev/JuMP.jl/stable/tutorials/linear/sudoku/

using JuMP

# The given digits
init_sol = [
    5 3 0 0 7 0 0 0 0
    6 0 0 1 9 5 0 0 0
    0 9 8 0 0 0 0 6 0
    8 0 0 0 6 0 0 0 3
    4 0 0 8 0 3 0 0 1
    7 0 0 0 2 0 0 0 6
    0 6 0 0 0 0 2 8 0
    0 0 0 4 1 9 0 0 5
    0 0 0 0 8 0 0 7 9
]

model = Model()

@variable(model, 1 <= x[1:9, 1:9] <= 9, Int);

# Then, we enforce that the values in each row must be all-different:

@constraint(model, [i = 1:9], x[i, :] in MOI.AllDifferent(9));

# That the values in each column must be all-different:

@constraint(model, [j = 1:9], x[:, j] in MOI.AllDifferent(9));

# And that the values in each 3x3 sub-grid must be all-different:

for i in (0, 3, 6), j in (0, 3, 6)
    @constraint(model, vec(x[i.+(1:3), j.+(1:3)]) in MOI.AllDifferent(9))
end

# Finally, as before we set the initial solution and optimize:

for i in 1:9, j in 1:9
    if init_sol[i, j] != 0
        fix(x[i, j], init_sol[i, j]; force = true)
    end
end

# Let's solve it with Chuffed:

import MiniZinc
set_optimizer(model, () -> MiniZinc.Optimizer{Float64}("chuffed"))

optimize!(model)

# We can see that it found a single feasible solution:

solution_summary(model)

csp_sol = round.(Int, value.(x))

# No reformulation needed:

print_active_bridges(model)


# Let's solve it with a MILP solver:

import HiGHS

set_optimizer(model, HiGHS.Optimizer)

optimize!(model)

solution_summary(model)

# Reformulation used is easy to inspect with:

print_active_bridges(model)

# Reformulation selected as a shortest path in a large graph of possible reformulations:

print_bridge_graph(model)
