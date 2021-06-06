
export zeroone

function zeroone(s::AbstractString, p=10^9+7)
    baseones = 0
    binom = [1]
    count = [0]
    q = 0
    for c in s
        if c == '0'
            for k = 0:q
                count[k+1] = mod(count[k+1] + baseones + k, p)
            end
        elseif c == '1'
            baseones += 1
        elseif c == '?'
            insert!(count, 1, 0)
            insert!(binom, 1, 0)
            for k = 0:q
                binom[k+1] = mod(binom[k+1] + binom[k+2], p)
                count[k+1] = mod(count[k+1] + count[k+2] + (k + baseones) * binom[k+2], p)
            end
            q += 1
        end
        # println(count)
    end
    sum(count), count
end
