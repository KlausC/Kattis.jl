module ZeroOne

export zeroone

function zeroone(s::AbstractString, p = 10^9 + 7)
    nvariants = 1
    nones = 0
    ninvol = 0
    for c in s
        if c === '1'
            nones = mod(nones + nvariants, p)
        elseif c === '0'
            ninvol = mod(ninvol + nones, p)
        elseif c === '?'
            ninvol = mod(ninvol * 2 + nones, p)
            nones = mod(nones * 2 + nvariants, p)
            nvariants = mod(nvariants * 2, p)
        end
    end
    ninvol
end

end # module
