using .Origami
using .Origami: evaluate

@testset "Origami" begin
    @test evaluate(Point{Float64}[],[], Point(0,0)) == 0
    @test evaluate([Point(0,0), Point(0,1000), Point(1000,1000), Point(1000,0), Point(0,0)], [], Point(1,1)) == 1
end