
module MaxFlow

export List, Node, Path, Stack
export pop, car, cdr, insert

# solve Kattis problem "https://open.kattis.com/problems/maxflow" using weighted graphs techniques

abstract type AbstractList{T} end

struct EmptyList{T} <: AbstractList{T}
end

struct List{T} <: AbstractList{T}
    head::T
    tail::AbstractList{T}
    List{T}() where T = EmptyList{T}()
    List(a::T) where T = new{T}(a, List{T}())
    List{T}(a::T) where T = new{T}(a, List{T}())
    List(a::T, b::List{T}) where T = new{T}(a, b)
    List{T}(a::T, b::List{T}) where T = new{T}(a, b)
end

AbstractList(p::T) where T = List(p)
AbstractList{T}(p::T) where T = List(p)
AbstractList{T}() where T = EmptyList{T}()
Base.show(io::IO, ::EmptyList) = print(io, "()")

car(a::List) = a.head
cdr(a::List) = a.tail
Base.isempty(::EmptyList) = true
Base.isempty(::List) = false

struct Node
    id
end
const Path = List{Node}
const Stack = AbstractList{<:Tuple{Path,<:Real}}

pop(s::Stack) = (car(s), cdr(s))
insert(s::EmptyList, t::Tuple{Path,R}) where R = Stack(t)
function insert(s::Stack, t::Tuple{Path,R}) where R
    top = car(s)
    if t[2] < top[2]
        Stack(t, s)
    else
        Stack(top, insert!(cdr(s), t))
    end
end

function insert(t::Tuple{Path,R}, n::Node, v::R) where R
    Path(n, t[1]), v < t[2] ? v : t[2]
end
insert(n::Node, v::R) where R = Path(n), v

end
