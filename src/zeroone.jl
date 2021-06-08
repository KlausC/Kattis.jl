
export zeroone

zeroone(x::AbstractString, p = 10^9 + 7) = sum(_zeroone(x, p)[2])

function _zeroone(s::AbstractString, p::Integer)
    baseones = 0
    R = promote_type(typeof(p), Int)
    binom = R[1]
    count = R[0]
    q = 0
    for c in s
        if c == '0'
            for k = 0:q
                count[k+1] = mod(count[k+1] + baseones + k, p)
            end
        elseif c == '1'
            baseones += 1
        elseif c == '?'
            push!(count, count[end])
            push!(binom, binom[end])
            for k = q:-1:1
                count[k+1] = mod(count[k+1] + count[k] + mulmod(k + baseones, binom[k+1], p), p)
                binom[k+1] = mod(binom[k+1] + binom[k], p)
            end
            count[1] = mod(count[1] + baseones, p)
            binom[1] = 1
            q += 1
        end
        # println(count)
    end
    baseones, count, binom
end

@inline mulmod(a::T, b::T, p::T) where T<:BigInt = mod(a * b, p)
@inline function mulmod(a::T, b::T, p::T) where T<: Base.BitInteger
    ab, ov = Base.mul_with_overflow(a, b)
    ov ? T(mod(widemul(a, b), p)) : mod(ab, p)
end

function zeroone_compose(p::Integer, t::Tuple...)
    length(t) <= 1 && return t
    t1, t2 = t
    o1, c1, b1 = t1
    o2, c2, b2 = t2
    q1 = length(c1) - 1
    q2 = length(c2) - 1
    q = q1 + q2
    c = similar(c1, q + 1)
    b = similar(b1, q + 1)
    for k = 0:q
        sb = 0
        sc = 0
        for j = max(k - q2, 0):min(k, q1)
            b1j = b1[j+1]
            b2j = b2[k-j+1]
            b12 = mulmod(b1j, b2j, p)
            sb = mod(sb + b12, p)
            sc = mod(sc + mulmod(c1[j+1], b2j, p) + mulmod(c2[k-j+1], b1j, p) + mulmod(mulmod((o1 + j), (q2 - o2 - k + j), p), b12,p), p)
        end
        b[k+1] = sb
        c[k+1] = sc
    end
    o1, c, b
end
