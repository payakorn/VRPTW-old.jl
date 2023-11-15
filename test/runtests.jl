using VRPTW
using Test

@testset verbose = true begin
    
    # load solomon data for 25
    @testset "load solomon data 25" begin
        num_node = 25
        instance = load_solomon_data("r101", num_node=num_node)
        @test instance.num_node == num_node
        @test length(instance.service_time) == num_node + 1
        @test length(instance.demand) == num_node + 1
    end
    
    
    # load solomon data for 50
    @testset "load solomon data 50" begin
        num_node = 50
        instance = load_solomon_data("r101", num_node=num_node)
        @test instance.num_node == num_node
        @test length(instance.service_time) == num_node + 1
        @test length(instance.demand) == num_node + 1
    end
    
    # load solomon data for 100
    @testset "load solomon data 100" begin
        instance = load_solomon_data("r101")
        @test instance.num_node == 100
        @test length(instance.service_time) == 101
        @test length(instance.demand) == 101
    end
    
    
    @testset "load Solution from SA" begin
        @test load_solution_SA(:C101) |> distance >= 0
        @test load_solution_SA("C101", distance, 100, 1) |> distance >= 0
        @test load_solution_SA("C101", distance, 25, 1) |> distance >= 0
        @test load_solution_SA("C101", distance, 50, 1) |> distance >= 0
        @test load_solution_SA("C101", distance, 100, 1) |> distance >= 0
    end
end
