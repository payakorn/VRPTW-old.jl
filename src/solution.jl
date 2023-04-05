mutable struct Solution
    route::Array{Integer}
    problem::Problem
    distance::Float64
    # check
    Solution(route, problem, distance) = route[1] != 0 || route[end] != 0 ? error("This is not a route representation\nmust start with 0 and end with 0\n i.e. [0, 1, 2, 3, 0, 4, 5, 6, 0, 7, 8, 0]") : new(route, problem, distance)
    function Solution(route, problem)
        new(route, problem, length(route))
    end
end


struct Point
    x::Float64
    y::Float64
end


function fix_route_zero(route::Array)
    delete_position = Integer[]
    if route[1] != 0 || route[end] != 0
        return false
    elseif length(route) > 2
        zero_position = findall(x -> x == 0, route)
        for i in (length(zero_position)-1):-1:1
            if zero_position[i+1] - zero_position[i] == 1
                push!(delete_position, zero_position[i])
            end
        end
    end
    for i in delete_position
        route = deleteat!(route, i)
    end
    return route
end


function route_length(route::Array)
    fix_route_zero(route)
    return length(findall(x -> x == 0, route)) - 1
end


function route_length(solution::Solution)
    route_length(solution.route)
end


function distance(point1::Point, point2::Point)
    sqrt((point1.x^2 - point1.x)^2 + (point2.x^2 - point2.x)^2)
end


function distance(route::Array, distance_matrix::Matrix)
    route = fix_route_zero(route)
    dis = 0.0
    for i in 1:length(route)-1
        dis += distance_matrix[route[i], route[i+1]]
    end
end


function distance(solution::Solution)
    nothing
end


function empty_solution(problem::Problem)
    route = [0, 0]
    return Solution(route, problem, zero(1))
end


function swap!(solution::Solution, pos1::Integer, pos2::Integer)
    solution.route[pos1], solution.route[pos2] = solution.route[pos2], solution.route[pos1]
    return Solution(solution.route, solution.problem)
end


function add!(solution::Solution, pos::Integer, cus::Integer)
    route = solution.route
    splice!(route, pos, cus)
    return Solution(route, solution.problem)
end


function splice!(solution::Solution, pos::Integer, cus::Integer)
    route = solution.route
    splice!(route, pos, cus)
    return Solution(route, solution.problem)
end


function dict_to_solution(d::Dict)
    sol_list = try deepcopy(d[1]) catch e; deepcopy(d["1"]) end
    for i in 2:(length(d))
        try append!(sol_list, d[i][2:end]) catch e; append!(sol_list, d["$i"][2:end]) end
    end
    return sol_list
end


function find_route(solution::Array)
    zero_position = findall(x->x==0, solution)
    num_vehicle = length(zero_position) - 1

    route = Dict()

    for k in 1:num_vehicle
        route[k] = solution[(zero_position[k]):(zero_position[k+1])]
    end
    return route
end


function max_completion_time_and_feasible(solution::Solution)
    num_vehicle = route_length(solution)
    max_com = []
    total_com = zero(1)
    route = find_route(solution.route)

    for k in 1:num_vehicle
        t = zero(1)
        c = zero(1)
        for i in 1:(length(route[k])-2)

            # chack time window
            if t + solution.problem.service_time[route[k][i]+1] + solution.problem.distance[route[k][i]+1, route[k][i+1]+1] <= solution.problem.lower_time_window[route[k][i+1]+1]
                t = solution.problem.lower_time_window[route[k][i+1]+1]
            else
                t += solution.problem.service_time[route[k][i]+1] + solution.problem.distance[route[k][i]+1, route[k][i+1]+1]
            end
            # calculate completion time
            c = t + solution.problem.service_time[route[k][i+1]+1]

            # calculate total completion time
            total_com += c
        end
        push!(max_com, c)
    end
    return max_com, total_com
end


function load_solution(ins_name::String)
    js = JSON.parsefile(dir("data", "opt_solomon", "balancing_completion_time", "$ins_name.json"))
    route = dict_to_solution(js["route"])
    (ins_name, num_node) = split(js["name"], "-")
    problem = load_solomon_data(String(ins_name), num_node=parse(Int64, num_node))
    Solution(route, problem)
end


function list_ins_name()
    NameNumVehicle = CSV.File(dir("data", "solomon_opt_from_web", "Solomon_Name_NumCus_NumVehicle.csv"))
    Ins_name = [String("$(NameNumVehicle[i][1])-$(NameNumVehicle[i][2])") for i in 1:(length(NameNumVehicle))]
    Num_vehicle = [NameNumVehicle[i][3] for i in 1:(length(NameNumVehicle))]
    return Ins_name, Num_vehicle
end


function read_opt_json(location::String)
    return JSON.parsefile(location)
end


function read_optimal_solution()

    # list of variables
    # 1
    balancing1 = []
    total_com1 = []
    solve_time1 = []
    relative_gap1 = []

    # 2
    balancing2 = []
    total_com2 = []
    solve_time2 = []
    relative_gap2 = []

    Ins_name, Num_vehicle = list_ins_name()
    for (ins_name) in Ins_name

        @info "reading $ins_name"

        location1 = dir("data", "opt_solomon", "balancing_completion_time", "$ins_name.json") 
        location2 = dir("data", "opt_solomon", "total_completion_time", "$ins_name.json") 
        if isfile(location1) && isfile(location2)
            js1 = read_opt_json(location1)
            js2 = read_opt_json(location2)
            
            # add elements
            push!(balancing1, js1["obj_function"])
            push!(balancing2, js2["obj_function"])
            
            # total completion time
            push!(total_com1, js1["total_com"])
            push!(total_com2, js2["total_com"])
            
            # solve time
            push!(solve_time1, js1["solve_time"])
            push!(solve_time2, js2["solve_time"])
            
            # relative gap
            push!(relative_gap1, js1["relative_gap"])
            push!(relative_gap2, js2["relative_gap"])
            
        elseif isfile(location1)

            js1 = read_opt_json(location1)
            
            # add elements
            push!(balancing1, js1["obj_function"])
            push!(balancing2, Inf)

            # total completion time
            push!(total_com1, js1["total_com"])
            push!(total_com2, Inf)

            # solve time
            push!(solve_time1, js1["solve_time"])
            push!(solve_time2, Inf)

            # relative gap
            push!(relative_gap1, js1["relative_gap"])
            push!(relative_gap2, 1)
            
        elseif isfile(location2)
            
            js2 = read_opt_json(location2)

            # add elements
            push!(balancing1, Inf)
            push!(balancing2, js2["obj_function"])

            # total completion time
            push!(total_com1, Inf)
            push!(total_com2, round(js2["total_com"], digits=1))

            # solve time
            push!(solve_time1, Inf)
            push!(solve_time2, js2["solve_time"])

            # relative gap
            push!(relative_gap1, 1)
            push!(relative_gap2, js2["relative_gap"])
            
        else
            # add elements
            push!(balancing1, Inf)
            push!(balancing2, Inf)

            # total completion time
            push!(total_com1, Inf)
            push!(total_com2, Inf)

            # solve time
            push!(solve_time1, Inf)
            push!(solve_time2, Inf)

            # relative gap
            push!(relative_gap1, 1)
            push!(relative_gap2, 1)
        end
    end
    return DataFrame(ins_name=Ins_name, num_vehi=Num_vehicle, diff_b=balancing1, diff_t=balancing2, total_b=total_com1, total_t=total_com2, relative_gap_b=round.(relative_gap1, digits=3), relative_gap_t=round.(relative_gap2, digits=3), solve_time_b=round.(solve_time1, digits=2), solve_time_t=round.(solve_time2, digits=2))
end


function save_csv_optimal()
    df = read_optimal_solution()
    CSV.write(dir("data", "simulations", "diff_and_total_com_opt.csv"), df)
end


function asdf()
    x = 1:8
end