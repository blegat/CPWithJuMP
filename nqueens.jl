using LinearAlgebra
using JuMP

function nqueens(n, T)
    model = GenericModel{T}()
    @variable(model, 1 <= x[1:n] <= n, Int)
    @constraint(model, x in MOI.AllDifferent(n))
    @constraint(model, [x[i] + i for i in 1:n] in MOI.AllDifferent(n))
    @constraint(model, [x[i] - i for i in 1:n] in MOI.AllDifferent(n))
    return model
end

n = 8
import MiniZinc
model = nqueens(8, Int)
set_optimizer(model, () -> MiniZinc.Optimizer{Int}("chuffed"))
optimize!(model)
solution_summary(model)

using SparseArrays
sparse(value.(model[:x]), 1:n, ones(Int, n))

MOI.set(model, MOI.SolutionLimit(), 25)
optimize!(model)
solution_summary(model)

for i in 1:25
    display(sparse(value.(model[:x], result = i), 1:n, ones(Int, n)))
end

MOI.set(model, MOI.SolutionLimit(), 100)
optimize!(model)
solution_summary(model)
result_count(model)

import HiGHS
model = nqueens(8, Float64)
set_optimizer(model, HiGHS.Optimizer)
optimize!(model)
solution_summary(model)

sparse(round.(Int, value.(model[:x])), 1:n, ones(Int, n))
