
module MaxFlow

export Graph, PathWeight, Path, WeightedPath

# solve Kattis problem "https://open.kattis.com/problems/maxflow" using weighted graphs techniques

struct Graph{T}
    n::Int
    node::Vector{Vector{Int}}
    weight::Vector{Vector{T}}
end

struct PathWeight{T}
    weight::T
    length::Int
    PathWeight(w::T, d::Integer) where T = new{T}(w, d)
end

struct Path
    id::Int
    next::Union{Path,Nothing}
    Path(id::Integer) = new(id, nothing)
    Path(id::Integer, p::Path) = new(id, p)
end

struct WeightedPath{T}
    path::Path
    cweight::PathWeight{T}
    WeightedPath(id::Integer, w::T) where T = new{T}(Path(id), PathWeight(w, 0))
    WeightedPath(id::Integer, w::T, wp::WeightedPath{T}) where T = new{T}(Path(id, wp.path), combine_weights(w, wp.cweight))
end

struct Stack{T}
    a::Vector{WeightedPath{T}}
    Stack(wp::WeightedPath{T}) where T = new{T}([wp])
end

function Graph(n, ii, jj, aa::AbstractVector{T}) where T
    m = length(ii)
    @assert m == length(jj) == length(aa)
    node = Vector{Vector{Int}}(undef, n)
    weight = Vector{Vector{T}}(undef, n)
    for i = 1:n
        node[i] = zeros(Int, 0)
        weight[i] = Vector{T}(undef, 0)
    end
    kk = 0
    for k = 1:m
        i, j, a = ii[k], jj[k], aa[k]
        @assert 0 <= i < n
        @assert 0 <= j < n
        nodei = node[i+1]
        weighti = weight[i+1]
        ix = findfirst(isequal(j), nodei)
        if ix === nothing
            push!(nodei, j)
            push!(weighti, a)
        else
            weighti[ix] += a
        end
    end
    Graph(n, node, weight)
end

function main(io::IO...)
    n, s, t, graph0 = read_data(io...)
    print_results(n, 0, graph0)
    f, graph = run(n, s, t, graph0)
    print_results(n, f, graph)
end

function run(n, s, t, graph::Graph{T}) where T
    @assert 0 <= s < n
    @assert 0 <= t < n
    graph = deepcopy(graph)
    akkug = Graph(n, Int[], Int[], T[])
    sum = 0
    wp = bestpath(graph, s, t)
    while is_adding(wp, s, t)
        sum += wp.cweight.weight
        add!(akkug, wp)
        sub!(graph, wp)
        wp = bestpath(graph, s, t)
    end
    sum, akkug
end

"""
    bestpath(g::Graph, s, t)

best path in `g` from node `s` to node `t`
"""
function bestpath(graph::Graph{T}, s, t) where T
    w = typemax(T)
    res = WeightedPath(s, w)
    stack = Stack(res)

    while !isempty(stack)
        top = pop!(stack)
        if top.path.id == t
            res = top
            break
        end
        for c in children(top, graph)
            if is_eligible(c)
                insert_sorted!(stack, c)
            end
        end
    end
    res
end

function is_adding(wp::WeightedPath, s, t)
    wp.path.id == t && !iszero(wp.cweight.weight)
end

is_eligible(wp::WeightedPath) = !is_cyclictop(wp.path)

function is_cyclictop(p::Path)
    ( p.next === nothing || p.next.next == nothing ) && return false
    is_cyclictop(p.next, p.id)
end
is_cyclictop(::Nothing, id) = false
is_cyclictop(p::Path, id) = p.id == id || is_cyclictop(p.next, id)

sub!(g::Graph{T}, wp::WeightedPath{T}) where T = _add(g, -1, wp)
add!(g::Graph{T}, wp::WeightedPath{T}) where T = _add(g, 1, wp)
function _add(g::Graph{T}, sig, wp::WeightedPath{T}) where T
    w = wp.cweight.weight * sig
    p = wp.path
    t = p.id
    while p.next !== nothing
        p = p.next
        s = p.id
        _add(g, s, t, w)
        t = s
    end
    nothing
end

function _add(g, s, t, w)
    node, weight = g.node[s+1], g.weight[s+1]
    k = findfirst(isequal(t), node)
    if k === nothing
        if !iszero(w)
            push!(node, t)
            push!(weight, w)
        end
    else
        nw = weight[k] + w
        if iszero(nw)
            deleteat!(node, k)
            deleteat!(weight, k)
        else
            weight[k] = nw
        end
    end
    nothing
end

function Base.pop!(s::Stack)
    popat!(s.a, 1)
end

function children(wp::WeightedPath{T}, g::Graph{T}) where T
    id = wp.path.id
    node = g.node[id+1]
    weight = g.weight[id+1]
    [WeightedPath(node[c], weight[c], wp) for c in 1:length(node)]
end


function insert_sorted!(st::Stack{T}, wp::WeightedPath{T}) where T
    insert_sorted!(st.a, 1, wp)
end
function insert_sorted!(awp::AbstractArray{WeightedPath{T}}, ix::Integer, wp::WeightedPath{T}) where T
    if ix > length(awp)
        insert!(awp, ix, wp)
    else
        top = awp[ix]
        if wp.path.id == top.path.id
            if wp.cweight < top.cweight
                awp[ix] = wp
            end
        elseif wp.cweight < top.cweight
            insert!(awp, ix, wp)
            delete_sorted!(awp, ix+1, wp)
        else
            insert_sorted!(awp, ix+1, wp)
        end
    end
    nothing
end

function delete_sorted!(awp::AbstractArray{WeightedPath{T}}, ix::Integer, wp::WeightedPath{T}) where T
    ix > length(awp) && return
    top = awp[ix]
    if wp.path.id == top.path.id
        deleteat!(awp, ix)
    else
        delete_sorted!(awp, ix+1, wp)
    end
end

function combine_weights(w::T, pw::PathWeight{T}) where T
    PathWeight(min(w, pw.weight), pw.length + 1)
end

function Base.isless(a::PathWeight{T}, b::PathWeight{T}) where T
    a.weight > b.weight || isequal(a.weight, b.weight) && a.length < b.length
end

Base.isempty(s::Stack) = isempty(s.a)
weight(g::Graph) = sum(sum.(g.weight))

# utilities
function read_data(io::IO=stdin)
    line = split(readline(io))
    n, m, s, t = parse.(Int, line)
    ii, jj, aa = Vector{Int}.(undef, (m, m, m))
    for k = 1:m
        i, j, a = parse.(Int, split(readline(io)))
        ii[k] = i
        jj[k] = j
        aa[k] = a
    end
    n, s, t, Graph(n, ii, jj, aa)
end

function print_results(n, f, g::Graph)
    n = length(g.node)
    m = sum(length.(g.weight))
    println("$n $f $m")
    for s = 0:n-1
        node = g.node[s+1]
        weight = g.weight[s+1]
        for k = 1:length(node)
            t = node[k]
            w = weight[k]
            println("$s $t $w")
        end
    end
end

function Base.show(io::IO, p::Path)
    print(io, "Path(", p.id)
    _showrest(io, p)
end
function _showrest(io::IO, p::Path)
    if p.next === nothing
        print(io, ")")
    else
        print(io, " ← ", p.next.id)
        _showrest(io, p.next)
    end
end

Base.show(io::IO, pw::PathWeight) = print(io, "Weight", (pw.weight, pw.length))
Base.show(io::IO, wp::WeightedPath) = print(io, (wp.path, wp.cweight))
   

end #module