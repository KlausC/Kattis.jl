using .Origami
using .Origami: evaluate

const P = Point{Float64}

@testset "Origami" begin
    @test evaluate(P[],[], P(0,0)) == 0
    shape = [P(0,0), P(0,1000), P(1000,1000), P(1000,0), P(0,0)]
    @test evaluate(shape, [], P(1,1)) == 1
    folds = [(P(-5,-5), P(10,10)), (P(10,750), P(0,750))]
    probes = [P(100,600), P(800,600), P(300,400), P(100,100), P(500,500), P(200,500)]
    result = [4, 2, 2, 0, 0, 2]
    for (p, r) in zip(probes, result)
        @test evaluate(shape, folds, p) == r
    end
end