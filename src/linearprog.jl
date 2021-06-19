module LinearProg

# solve Kattis problem "https://open.kattis.com/problems/maxflow" using linear optimization

export ixedge, modeldata

using JuMP
import Clp

ixedge(i, j, n) = (2n - i) * (i - 1) ÷ 2 + j - i

function modeldata(model, n, (ii, jj, aa), s, t)
    m = length(ii)
    @assert m == length(jj) == length(aa)
    x = Dict()
    ex = [AffExpr(0.0) for i = 1:n]
    for k = 1:m
        i, j, a = ii[k], jj[k], aa[k]
        @assert 0 <= i < j < n
        @assert a >= 0.0
        xij = @variable(model, lower_bound=0, upper_bound=a)
        set_name(xij, "x[$i,$j]")
        x[i,j] = xij
        add_to_expression!(ex[i+1], 1.0, xij)
        add_to_expression!(ex[j+1], -1.0, xij)
    end
    @objective(model, Max, ex[s+1])
    con = Vector{Any}(undef, n - 2)
    j = 0
    for k = 1:n
        if !(k-1 in (s, t))
            j += 1
            con[j] = @constraint(model, ex[k] == 0)
        end
    end
    model
end

function main(io::IO...)
    n, s, t, ii, jj, aa = read_data(io...)
    run(n, s, t, ii, jj, aa)
end

function run(n, s, t, ii, jj, aa)
    model = Model()
    set_optimizer(model, Clp.Optimizer)
    set_optimizer_attribute(model, MOI.Silent(), true)
    modeldata(model, n, (ii, jj, aa), s, t)
    print(model)
    optimize!(model)
    # solution_summary(model)
    # println(termination_status(model))
    # println(objective_value(model))
    print_result(n, model)
end


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
    n, s, t, ii, jj, aa
end

function print_result(n, model)
    var = all_variables(model)
    val = value.(var)
    m = count(val .!= 0)
    println("$n $(Int(objective_value(model))) $m")
    for l = 1:length(var)
        a = Int(round(val[l]))
        a == 0 && continue
        i, j = var2ij(var[l])
        println("$i $j $a")
    end
    nothing
end

function var2ij(var)
    str = split(split(split(string(var), '[')[2], ']')[1], ',')
    parse.(Int, str)
end

end
