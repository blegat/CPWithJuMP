# Inspired from `MiniZinc.jl/test/examples/louvain.jl`

w = Int[]

edges = [(1, 2, 1); (1, 3, 4); (1, 5, 7); (2, 4, 10); (3, 5, 12)] # edges and weights

n_nodes = maximum(max(e[1], e[2]) for e in edges)
m = sum(e[3] for e in edges)
k = [
    sum((w for (u, v, w) in edges if (u == i || v == i)), init = 0) for
    i in 1:n_nodes
]
n_communities = 2
model = GenericModel{Int}()
# setup model
@variable(model, 1 <= x[i=1:n_nodes] <= n_communities, Int)
# Break symmetry by forcing first node to be in first community
fix(x[1], 1; force = true)
@objective(
    model,
    Max,
    sum(
        ifelse(
            x[u] == x[v],
            2 * m * w - k[u] * k[v],
            0,
        )
        for (u, v, w) in edges
    ),
)

import MiniZinc
set_optimizer(model, () -> MiniZinc.Optimizer{Int}("chuffed"))
optimize!(model)

termination_status(model)
value.(x)

using Graphs
function graph(edges, n_nodes)
    G = DiGraph(n_nodes)
    w = Int[]
    for e in edges
        add_edge!(G, e[1], e[2])
        push!(w, e[3])
    end
    return G, w
end

G, w = graph(edges, n_nodes)
using Colors
colors = distinguishable_colors(2, [RGB(1,1,1), RGB(0,0,0)], dropseed = true);
using GraphPlot
gplot(G, nodesize=0.1, nodelabel = 1:nv(G), edgelabel = w, nodefillc = colors[value.(x)])
