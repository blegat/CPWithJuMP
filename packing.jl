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

using Colors, Plots

function square_plot(x, y, s)
    n = length(x)
    colors = distinguishable_colors(n)
    p = plot(width = upper_bound, height = upper_bound, ratio = :equal, ticks = false, showaxis = false)
    for i in 1:n
        a, b, l = x[i], y[i], s[i]
        plot!(
            [a, a, a + l, a + l],
            [b, b + l, b + l, b],
            color = colors[i],
            legend = false,
            seriestype = :shape,
            linewidth = 0,
        )
    end
    return p
end

square_plot(value.(x), value.(y), sizes)
