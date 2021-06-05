using Origami
using Test

using Origami: evaluate

@testset "Origami.jl" begin
    @test evaluate([],[],[]) == 0
    @test evaluate([[0,0], [0,1000], [1000,1000], [1000,0], [0,0]], [], [[1,1]]) == 1
end
