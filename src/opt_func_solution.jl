const all_obj_functions = (
    VRPTW.distance,
    VRPTW.total_comp,
    VRPTW.balancing_value_weighted_sum_w0_w10,
    VRPTW.balancing_value_weighted_sum_w1_w9,
    VRPTW.balancing_value_weighted_sum_w2_w8,
    VRPTW.balancing_value_weighted_sum_w3_w7,
    VRPTW.balancing_value_weighted_sum_w4_w6,
    VRPTW.balancing_value_weighted_sum_w5_w5,
    VRPTW.balancing_value_weighted_sum_w6_w4,
    VRPTW.balancing_value_weighted_sum_w7_w3,
    VRPTW.balancing_value_weighted_sum_w8_w2,
    VRPTW.balancing_value_weighted_sum_w9_w1,
    VRPTW.balancing_value_weighted_sum_w10_w0,
)


function show_opt_solution(x::Any, n::Integer, num_vehicle::Integer)
    tex = ""

    route = Dict()
    for k in 1:num_vehicle
        route[k] = [0]

        job = 0
        for j in 1:n
            if abs(value.(x[0, j, k]) - 1.0) <= 1e-4
                job = deepcopy(j)
                push!(route[k], job)
                break
            end
        end

        iter = 1
        while job != 0 && iter <= n + 1
            iter += 1
            for j in setdiff(0:n, job)
                if abs(value.(x[job, j, k]) - 1.0) <= 1e-4
                    job = deepcopy(j)
                    push!(route[k], job)
                    break
                end
            end
        end
    end


    for k in 1:num_vehicle
        tex *= "vehicle $k: $(route[k])\n"
    end

    return tex, route
end

function print_solution()
    for k in K
        println("$k")
    end
end


function save_solution(route::Dict, ins_name::String, tex::String, m, t, CMAX, service; obj_function=distance::Function)

    new_route = dict_to_solution(route)

    solution = Solution(new_route, load_solomon_data(split(ins_name, "-")[1] |> String))

    # new version
    location = dir("data", "opt_solomon", obj_function)
    if isfile(location) == false
        mkpath(location)
    end

    # total distance 
    dis = solution |> distance

    # max completion time
    max_com = solution |> max_comp

    # total completion time
    total_com = solution |> total_comp
        
    # balancing
    bc = solution |> balancing_value

    d = Dict(
        "name"                  => ins_name, 
        "num_vehicle"           => length(route), 
        "route"                 => route, 
        "tex"                   => tex, 
        "distance"              => dis,
        "total_com"             => total_com,
        "max_completion_time"   => max_com, 
        "balancing"             => bc,
        "obj_func"              => "$(obj_function)",
        "obj_value"             => JuMP.objective_value(m),
        "solve_time"            => solve_time(m), 
        "relative_gap"          => relative_gap(m), 
        "solver_name"           => solver_name(m), 
    )


    # if obj_function == "balancing_completion_time"
    #     # check location
    #     location = dir("data", "opt_solomon", "balancing_completion_time")
    #     # location = joinpath(@__DIR__, "..", "" "opt_solomon", "$name") 
    #     if isfile(location) == false
    #         mkpath(location)
    #     end

    #     # calculate max completion time
    #     max_com = Dict(k => value.(CMAX[k]) for k in 1:(length(route)))

    #     # total completion time
    #     total_com = sum([value.(t[i]) + service[i+1] for i in 1:(length(t)-1)])


    #     # create dict
    #     d = Dict("name" => ins_name, "num_vehicle" => length(route), "route" => route, "tex" => tex, "max_completion_time" => max_com, "obj_function" => JuMP.objective_value(m), "solve_time" => solve_time(m), "relative_gap" => relative_gap(m), "solver_name" => solver_name(m), "total_com" => total_com)
    # elseif obj_function == "balancing_completion_time_weighted_sum" || obj_function == "balancing_completion_time_weighted_sum_w1_w9" || obj_function == "balancing_completion_time_weighted_sum_w2_w8" || obj_function == "balancing_completion_time_weighted_sum_w3_w7" || obj_function == "balancing_completion_time_weighted_sum_w4_w6" || obj_function == "balancing_completion_time_weighted_sum_w5_w5" || obj_function == "balancing_completion_time_weighted_sum_w6_w4" || obj_function == "balancing_completion_time_weighted_sum_w7_w3" || obj_function == "balancing_completion_time_weighted_sum_w8_w2" || obj_function == "balancing_completion_time_weighted_sum_w9_w1" || obj_function == "balancing_completion_time_weighted_sum_w10_w0"
    #     # check location
    #     location = dir("data", "opt_solomon", obj_function)
    #     # location = joinpath(@__DIR__, "..", "" "opt_solomon", "$name") 
    #     if isfile(location) == false
    #         mkpath(location)
    #     end

    #     # calculate max completion time
    #     max_com = Dict(k => value.(CMAX[k]) for k in 1:(length(route)))

    #     # total completion time
    #     total_com = sum([value.(t[i]) + service[i+1] for i in 1:(length(t)-1)])


    #     # create dict
    #     d = Dict("name" => ins_name, "num_vehicle" => length(route), "route" => route, "tex" => tex, "max_completion_time" => max_com, "obj_function" => JuMP.objective_value(m), "solve_time" => solve_time(m), "relative_gap" => relative_gap(m), "solver_name" => solver_name(m), "total_com" => total_com)
    # elseif obj_function == "total_completion_time"
    #     location = dir("data", "opt_solomon", "total_completion_time")
    #     # location = joinpath(@__DIR__, "..", "" "opt_solomon", "$name") 
    #     if isfile(location) == false
    #         mkpath(location)
    #     end

    #     # calculate max completion time
    #     # max_com = Dict(k => value.(CMAX[route[k][end-1]]) for k in 1:(length(route)))
    #     max_com = Dict(k => value.(t[route[k][end-1]]) + service[route[k][end-1]+1] for k in 1:(length(route)))
        
    #     # balancing
    #     if length(route) == 1
    #         bc = 0.0
    #     else
    #         bc = sum([abs(max_com[i] - max_com[j]) for i in 1:length(route) for j in 1:length(route) if i < j])
    #     end

    #     # total completion time
    #     total_com = sum([value.(t[i]) + service[i+1] for i in 1:(length(t)-1)])

    #     # create dict
    #     d = Dict("name" => ins_name, "num_vehicle" => length(route), "route" => route, "tex" => tex, "max_completion_time" => max_com, "obj_function" => bc, "solve_time" => solve_time(m), "relative_gap" => relative_gap(m), "solver_name" => solver_name(m), "total_com" => JuMP.objective_value(m))
    # elseif obj_function == "max_completion_time"
    #     location = dir("data", "opt_solomon", "max_completion_time")
    #     # location = joinpath(@__DIR__, "..", "" "opt_solomon", "$name") 
    #     if isfile(location) == false
    #         mkpath(location)
    #     end

    #     # calculate max completion time
    #     max_com = Dict(k => value.(t[route[k][end-1]]) + service[route[k][end-1]+1] for k in 1:(length(route)))
    #     # balancing
    #     bc = sum([abs(value.(t[route[i][end-1]]) - value.(t[route[j][end-1]])) for i in 1:(length(route)) for j in 1:(length(route)) if i < j])

    #     # total completion time
    #     total_com = sum([value.(t[i]) + service[i+1] for i in 1:(length(t)-1)])

    #     # create dict
    #     d = Dict("name" => ins_name, "num_vehicle" => length(route), "route" => route, "tex" => tex, "max_completion_time" => max_com, "obj_function" => bc, "solve_time" => solve_time(m), "relative_gap" => relative_gap(m), "solver_name" => solver_name(m), "total_com" => total_com)
    # elseif obj_function == "total_distance"
    #     location = dir("data", "opt_solomon", "total_distance")
    #     # location = joinpath(@__DIR__, "..", "" "opt_solomon", "$name") 
    #     # if isfile(location) == false
    #     #     mkpath(location)
    #     # end
    #     try mkpath(location) catch e; nothing end

    #     # calculate max completion time
    #     max_com = Dict(k => value.(t[route[k][end-1]]) + service[route[k][end-1]+1] for k in 1:(length(route)))

    #     # balancing
    #     bc = sum([abs(value.(t[route[i][end-1]]) - value.(t[route[j][end-1]])) for i in 1:(length(route)) for j in 1:(length(route)) if i < j])

    #     # total completion time
    #     total_com = sum([value.(t[i]) + service[i+1] for i in 1:(length(t)-1)])

    #     # find total distance (not complete)
    #     # total_dis = sum([value.(x[i, j, k]) for i in 1:l)

    #     # create dict
    #     d = Dict("name" => ins_name, "num_vehicle" => length(route), "route" => route, "tex" => tex, "max_completion_time" => max_com, "obj_function" => bc, "solve_time" => solve_time(m), "relative_gap" => relative_gap(m), "solver_name" => solver_name(m), "total_com" => total_com)
    # elseif obj_function == "total_distance_compat"
    #     location = dir("data", "opt_solomon", "total_distance_compat")
    #     # location = joinpath(@__DIR__, "..", "" "opt_solomon", "$name") 
    #     if isfile(location) == false
    #         mkpath(location)
    #     end

    #     # calculate max completion time
    #     max_com = Dict(k => value.(t[route[k][end-1]]) + service[route[k][end-1]+1] for k in 1:(length(route)))
    #     # balancing
    #     bc = sum([abs(value.(t[route[i][end-1]]) - value.(t[route[j][end-1]])) for i in 1:(length(route)) for j in 1:(length(route)) if i < j])

    #     # total completion time
    #     total_com = sum([value.(t[i]) + service[i+1] for i in 1:(length(t)-1)])

    #     # create dict
    #     d = Dict("name" => ins_name, "num_vehicle" => length(route), "route" => route, "tex" => tex, "max_completion_time" => max_com, "obj_function" => bc, "solve_time" => solve_time(m), "relative_gap" => relative_gap(m), "solver_name" => solver_name(m), "total_com" => total_com)
    # end


    open(joinpath(location, "$ins_name.json"), "w") do io
        JSON3.pretty(io, d, JSON3.AlignmentContext(alignment=:Colon, indent=2))
    end
end
# 