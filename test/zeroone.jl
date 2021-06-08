using .ZeroOne

@testset "zeroone" begin
    @test zeroone("") == 0
    @test zeroone("01") == 0
    @test zeroone("10") == 1
    @test zeroone("1?0") == 4
    @test zeroone("0101?"^2) == 41
    @test zeroone("1?0?") == zeroone("1000") + zeroone("1001") + zeroone("1100") + zeroone("1101")
    @test zeroone.("?" .^ (1:10)) == [0, 1, 6, 24, 80, 240, 672, 1792, 4608, 11520]
    @test zeroone("?" ^ 23) == 530579456
    @test zeroone("?" ^ 24) == 157627897
    @test zeroone("?" ^ 500000) == 879720014
end