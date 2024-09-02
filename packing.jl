# Inspired from tutorial in https://www.minizinc.org/

# ## Data

# Number of squares
n = 6

# Size of each square
sizes = collect(1:n)
upper_bound = sum(sizes)

# ## Model

using JuMP
import MiniZinc
model = GenericModel{Int}(() -> MiniZinc.Optimizer{Int}("chuffed"))
@variable(model, size[i = 1:n] == sizes[i], Int)
@variable(model, 1 <= x[1:n] <= upper_bound, Int)
@variable(model, 1 <= y[1:n] <= upper_bound, Int)
@variable(model, 1 <= max_x <= upper_bound, Int)
@variable(model, 1 <= max_y <= upper_bound, Int)

for i in 1:n
    @constraint(model, x[i] + size[i] <= max_x)
    @constraint(model, y[i] + size[i] <= max_y)
end

@constraint(model, [x; y; size; size] in MiniZinc.MiniZincSet(
    "diffn",
    [1:n, n .+ (1:n), 2n .+ (1:n), 3n .+ (1:n)],
))

@objective(model, Min, max_x * max_y)

optimize!(model)

solution_summary(model)

value.(x)
value.(y)

using Luxor

colors = ["blue", "red", "brown", "orange", "green", "purple"]

scaling = 20

@draw begin
    Drawing(scaling * upper_bound, scaling * upper_bound)
    for i in 1:n
        sethue(colors[i])
        rect(
            Point(scaling * value(x[i]), scaling * value(y[i])),
            scaling * sizes[i],
            scaling * sizes[i],
            action = :fill,
        )
    end
end
