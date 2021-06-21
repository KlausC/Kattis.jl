using .MaxFlow

const data = [
    (in = """
        4 5 0 3
        0 1 10
        1 2 1
        1 3 1
        0 2 1
        2 3 10
        """,
    out = """
        4 3 5
        0 1 2
        0 2 1
        1 2 1
        1 3 1
        2 3 2
        """),
    (in = """
        2 1 0 1
        0 1 100000
        """,
    out = """
        2 100000 1
        0 1 100000
        """),
    (in = """
        2 1 1 0
        0 1 100000
        """,
    out = """
        2 0 0
        """)
]

@testset "MaxFlow" begin
@testset "Sample $i" for i in keys(data)
    ioin = IOBuffer(data[i].in)
    ioout = IOBuffer()
    MaxFlow.main(ioin, ioout)
    @test String(take!(ioout)) == data[i].out
end
end