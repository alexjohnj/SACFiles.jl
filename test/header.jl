@testset "Header" begin
    @testset "Header Enums" begin
        let
            ids = vcat(-12345, 1:50, 52:97, 103)
            enums = collect(instances(HeaderEnum))
            @test enums == map(HeaderEnum, ids)
        end
    end
end
