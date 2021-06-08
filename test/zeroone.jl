using .ZeroOne

@testset "zeroone" begin
    @test zeroone("") == 0
    @test zeroone("01") == 0
    @test zeroone("10") == 1
    @test zeroone("1?0") == 4
    @test zeroone("0101?"^2) == 41
    @test zeroone.("?" .^ (1:10)) == [0, 1, 6, 24, 80, 240, 672, 1792, 4608, 11520]
end