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
    location = dir("../ResultsVRPTW", "opt_solomon", obj_function)
    if isfile(location) == false
        mkpath(location)
    end

    # total distance 
    dis = solution |> distance

    # max completion time
    max_com = solution |> max_comp

    # total completion time
    total_com = solution |> total_comp

    # total finishing time
    total_finish = solution |> total_max_comp
        
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
        "total_finishing_time"  => total_finish,
        "obj_func"              => "$(obj_function)",
        "obj_value"             => JuMP.objective_value(m),
        "solve_time"            => solve_time(m), 
        "relative_gap"          => relative_gap(m), 
        "solver_name"           => solver_name(m), 
    )

    open(joinpath(location, "$ins_name.json"), "w") do io
        JSON3.pretty(io, d, JSON3.AlignmentContext(alignment=:Colon, indent=2))
    end
end
# 