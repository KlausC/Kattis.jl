export Origami
module Origami

export evaluate, Point, Fold

using Base.Iterators

struct Point{T}
    x::T
    y::T

    function Point(x::S, y::T) where {S,T}
        R = promote_type(S, T)
        R = typeof(R(1) / R(1))
        new{R}(convert(R, x), convert(R, y))
    end
    Point{S}(x::T, y::T) where {S,T} = Point(convert(S, x), convert(S, y))
end
import Base: -
-(a::Point, b::Point) = Point(a.x - b.x, a.y - b.y)

const ArrayOrTuple{X} = Union{AbstractArray{X},NTuple{N,X} where N}
const Shape{T} = ArrayOrTuple{Point{T}}
const Fold{T} = Tuple{Point{T},Point{T}}
const Folds{T} = ArrayOrTuple{Fold{T}}

function evaluate(shape::Shape{T}, folds, probe::Point{T}) where T
    if isempty(folds)
        Int(inshape(probe, shape))
    else
        fold = first(folds)
        shape1, shape2 = split_and_fold(shape, fold)
        folds2 = drop(folds, 1)
        evaluate(shape1, folds2, probe) + evaluate(shape2, folds2, probe)
    end
end

function inshape(point::Point, shape::Shape)
    length(shape) <= 3 && return false
    y = point.y
    p0 = shape[1]
    r = 0
    for k = 2:length(shape)
        p1 = shape[k]
        if min(p0.y, p1.y) <= y <= max(p1.y, p0.y)
            x = atsideof(point, (p0, p1))
            (x == 0 || 0 != r != x) && return false
            r = x
        end
        p0 = p1
    end
    r != 0
end

split_and_fold(shape::Shape, fold::Fold) = foldifright.(split(shape, fold), Ref(fold))
foldifright(shape::Shape, fold::Fold) = isrightof(shape, fold) ? folded(shape, fold) : shape

function isrightof(shape::Shape, fold)
    all(atsideof.(shape, Ref(fold)) .>= 0)
end

# returns -1: left, 1: right, 0: on line
function atsideof(point::Point, fold::Fold)
    p1, p2 = fold
    p= p2 - p1
    q = point - p1
    a = p.y * q.x - p.x * q.y
    a * a * 10^12 > (p.x^2 + p.y^2) ? (a < 0 ? -1 : 1) : 0 
end

function folded(shape::Shape, fold::Fold)
    isempty(shape) ? shape : folded.(shape, Ref(fold))
end

function folded(point::Point, fold::Fold)
    A, p = matrix_vector(fold)
    v = A * ([point.x; point.y] - p) + p
    Point(v...)
end

function matrix_vector(fold::Fold)
    p1, p2 = fold
    dp = p2 - p1
    x, y = dp.x, dp.y
    c = x^2 + y^2
    a = (x^2 - y^2) / c
    b = (x * y * 2) / c
    [a b; b -a], [p1.x; p1.y]
end

function split(shape::Shape, fold::Fold)
    isempty(shape) && return shape, shape
    v = shape[1]
    side0 = atsideof(v, fold)
    shape1 = empty(shape)
    shape2 = empty(shape)
    switch(sh) = sh === shape1 ? shape2 : shape1
    sh = shape1
    push!(sh, v)
    for k = 2:length(shape)
        w = shape[k]
        side1 = atsideof(w, fold)
        if side1 == side0
            push!(sh, w)
        elseif side0 == 0
            side0 = side1
            push!(sh, w)
        elseif side1 == 0
            push!(sh, w)
            sh = switch(sh)
            push!(sh, w)
            side0 = -side0
        else
            u = intersect(v, w, fold)
            push!(sh, u)
            sh = switch(sh)
            push!(sh, u)
            push!(sh, w)
            side0 = side1
        end
        v = w
    end
    normal!(shape1), normal!(shape2)
end

function normal!(shape::AbstractArray)
    if length(shape) > 1 && shape[1] !== shape[end]
        push!(shape, shape[1])
    end
    if length(shape) <= 3
        empty!(shape)
    end
    shape
end

function intersect(x0::Point, x1::Point, fold::Fold)
    p0, p1 = fold
    dp = p1 - p0
    dx = x1 - x0
    b = p0 - x0
    a, _ = [dx.x dp.x; dx.y dp.y] \ [b.x; b.y]
    Point(a * dx.x + x0.x, a * dx.y + x0.y)
end 


end # module
