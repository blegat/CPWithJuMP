n = 6
using Random
Random.seed!(1234)
x = rand(n)
y = rand(n)

table = reduce(vcat, [[i, j, round(Int, 100hypot(x[i] - x[j], y[i] - y[j]))]' for i in 1:n for j in 1:n if i != j])

using JuMP
function tsp(n, table, T)
    model = GenericModel{T}()
    @variable(model, 1 <= next[1:n] <= n)
    @constraint(model, next in MOI.Circuit(n))
    @variable(model, cost[1:n])
    @constraint(model, [i = 1:n], [i, next[i], cost[i]] in MOI.Table(convert.(T, table)))
    @objective(model, Min, sum(cost))
    return model
end

model = tsp(n, table, Int)
import MiniZinc
set_optimizer(model, () -> MiniZinc.Optimizer{Int}("chuffed"))
optimize!(model)
solution_summary(model)

function extract_order(next)
    orders = Vector{Int}[]
    visited = falses(n)
    for start in 1:n
        if !visited[start]
            current = start
            order = Int[]
            while true
                visited[current] = true
                push!(order, current)
                current = next[current]
                if current == start
                    break
                end
            end
            push!(orders, order)
        end
    end
    return orders
end
order = extract_order(value.(model[:next]))

# We implement some plotting function in order to visualize our result.

using Plots
function tsp_plot(x, y, order)
    scatter(x, y, label="")
    for i in 1:n
        from = order[i]
        to = order[mod1(i + 1, n)]
        plot!([x[from], x[to]], [y[from], y[to]], label="", color=:black)
    end
    plot!()
end

tsp_plot(x, y, order[])
