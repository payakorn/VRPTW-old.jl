mutable struct Solution
    route::Array{Integer}
    problem::Problem
    obj_func::Function
    # check
    Solution(route, problem, obj_function) = route[1] != 0 || route[end] != 0 ? error("This is not a route representation\nmust start with 0 and end with 0\n i.e. [0, 1, 2, 3, 0, 4, 5, 6, 0, 7, 8, 0]") : new(route, problem, obj_function)
    function Solution(route, problem)
        new(route, problem, distance)
    end
end

# Solution(route, problem, obj_function) = Solution(route, problem, obj_function)


struct Point
    x::Float64
    y::Float64
end

const ins_names = [
    "C101",
    "C102",
    "C103",
    "C104",
    "C105",
    "C106",
    "C107",
    "C108",
    "C109",
    "C201",
    "C202",
    "C203",
    "C204",
    "C205",
    "C206",
    "C207",
    "C208",
    "R101",
    "R102",
    "R103",
    "R104",
    "R105",
    "R106",
    "R107",
    "R108",
    "R109",
    "R110",
    "R111",
    "R112",
    "R201",
    "R202",
    "R203",
    "R204",
    "R205",
    "R206",
    "R207",
    "R208",
    "R209",
    "R210",
    "R211",
    "RC101",
    "RC102",
    "RC103",
    "RC104",
    "RC105",
    "RC106",
    "RC107",
    "RC108",
    "RC201",
    "RC202",
    "RC203",
    "RC204",
    "RC205",
    "RC206",
    "RC207",
    "RC208",
]


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
    route = route .+ 1
    dis = 0.0
    for i in 1:length(route)-1
        dis += distance_matrix[route[i], route[i+1]]
    end
    return dis
end


function distance(solution::Solution)
    return distance(solution.route, solution.problem.distance)
end


function seperate_route(solution::Solution)::Dict

    routing = Dict()

    route = fix_route_zero(solution.route)
    zero_position = findall(x -> x == 0, route)
    num_vehi = length(zero_position) - 1

    for vehi in 1:num_vehi
        routing[vehi] = route[(zero_position[vehi]+1):(zero_position[vehi+1]-1)]
    end
    return routing
end


function check_time_window_capacity(solution::Solution)
    routing = seperate_route(solution)

    # capacity
    if any([sum(solution.problem.demand[routing[i].+1]) for i in 1:(length(routing))] .> solution.problem.vehicle_capacity)
        # @info "capacity false"
        return false
    end

    # time windows
    for i in 1:(length(routing))
        # @info "route $i"
        start_time = 0.0
        last_node = 0
        for node in routing[i]
            start_time += solution.problem.distance[last_node+1, node+1] + solution.problem.service_time[last_node+1]
            if start_time < solution.problem.lower_time_window[node+1]
                start_time = solution.problem.lower_time_window[node+1]
            elseif start_time > solution.problem.upper_time_window[node+1]
                return false
            end
            # println("node $node, start time: $(start_time), time window: [$(solution.problem.lower_time_window[node+1]), $(solution.problem.upper_time_window[node+1])]")
            last_node = node
        end
    end
    return true
end


function obj_value(solution::Solution)
    return solution.obj_func(solution)
end


function feasibility(solution::Solution)
    return check_time_window_capacity(solution)
end


function feasibility(route::Array, problem::Problem)
    feasibility(Solution(route, problem))
end


function empty_solution(problem::Problem)
    route = [0, 0]
    return Solution(route, problem)
end


function empty_solution(problem::Problem, obj_func::Function)
    route = [0, 0]
    return Solution(route, problem, obj_func)
end


function swap!(solution::Solution, pos1::Integer, pos2::Integer)
    solution.route[pos1], solution.route[pos2] = solution.route[pos2], solution.route[pos1]
    return Solution(solution.route, solution.problem, solution.obj_func)
end


function move!(solution::Solution, cus::Integer)
    new_sol = deepcopy(solution)
    deleteat!(new_sol.route, findfirst(x->x==cus, new_sol.route))
    new_sol = inserting(new_sol, cus, new_sol.obj_func)
    if feasibility(new_sol)
        return new_sol
    else
        return solution
    end
end


function moving_procedure(solution::Solution)
    obj = solution.obj_func
    best_solution = deepcopy(solution)
    all_posoble_position = shuffle(combinations(findall(x -> x != 0, solution.route), 2))
    # all_posoble_position = combinations(findall(x->x!=0, solution.route), 2)
    for (i, cus) in enumerate(shuffle(1:solution.problem.num_node))
        current_solution = deepcopy(best_solution)
        # @info "iteration $i, moving $cus"
        current_solution = move!(current_solution, cus)
        if feasibility(current_solution) && (obj(current_solution) < obj(best_solution))
            @info "new best found"
            # current_solution.obj_value = obj(current_solution)
            best_solution = deepcopy(current_solution)
            return best_solution
        end
    end
    @info "no new best found"
    return best_solution
end

function swapping_procedure(solution::Solution)
    obj = solution.obj_func
    best_solution = deepcopy(solution)
    all_posoble_position = shuffle(combinations(findall(x -> x != 0, solution.route), 2))
    # all_posoble_position = combinations(findall(x->x!=0, solution.route), 2)
    for (i, position) in enumerate(all_posoble_position)
        current_solution = deepcopy(best_solution)
        # @info "iteration $i, swapping between position $(position[1]) and position $(position[2])"
        current_solution.route[position[1]], current_solution.route[position[2]] = current_solution.route[position[2]], current_solution.route[position[2]]
        if feasibility(current_solution) && (obj(current_solution) < obj(best_solution))
            @info "new best found"
            # current_solution.obj_value = obj(current_solution)
            best_solution = deepcopy(current_solution)
            return best_solution
        end
    end
    @info "no new best found"
    return best_solution
end


function add!(solution::Solution, pos::Integer, cus::Integer)
    route = solution.route
    insert!(route, pos, cus)
    return Solution(route, solution.problem)
end


function inserting(solution::Solution, cus::Integer, obj::Function)

    # check if the node exist in the route
    if cus in solution.route
        return error("the inserting cusotomer already in the route")
    end

    save_route = deepcopy(solution.route)
    best_route = deepcopy(save_route)
    best_obj = Inf

    # insert in new route
    if route_length(solution) < solution.problem.max_vehi
        insert!(best_route, 1, cus)
        insert!(best_route, 1, 0)
        best_obj = obj(Solution(best_route, solution.problem, obj))
    end

    # @info "start inseting procedure with $(length(save_route)) positions"
    for i in 2:(length(solution.route)-1)
        inserted_route = deepcopy(save_route)
        insert!(inserted_route, i, cus)
        new_obj = obj(Solution(inserted_route, solution.problem, obj))

        # show information
        # println("insert in position $i,  best obj: $best_obj,   new obj: $new_obj")

        # update best route
        if new_obj <= best_obj && feasibility(inserted_route, solution.problem)
            best_obj = deepcopy(new_obj)
            best_route = deepcopy(inserted_route)
        end

    end
    return Solution(fix_route_zero(best_route), solution.problem, obj)
end


function inserting_procedure(problem::Problem, obj::Function)
    solution = empty_solution(problem, obj)
    all_nodes = 1:solution.problem.num_node
    for node in all_nodes
        solution = inserting(solution, node, obj)
    end
    return solution
end


function splice!(solution::Solution, pos::Integer, cus::Integer)
    route = solution.route
    splice!(route, pos, cus)
    return Solution(route, solution.problem)
end


function dict_to_solution(d::Dict)
    sol_list = try
        deepcopy(d[1])
    catch e
        deepcopy(d["1"])
    end
    for i in 2:(length(d))
        try
            append!(sol_list, d[i][2:end])
        catch e
            append!(sol_list, d["$i"][2:end])
        end
    end
    return sol_list
end


function find_route(solution::Array)
    zero_position = findall(x -> x == 0, solution)
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
        for i in 1:(length(route[k])-1)

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


function max_comp(solution::Solution)
    max_com, ~ = max_completion_time_and_feasible(solution)
    return max_com
end


function total_max_comp(solution::Solution)
    return sum(max_comp(solution))
end


function total_comp(solution::Solution)
    ~, total_com = max_completion_time_and_feasible(solution)
    return total_com
end


function load_solution(location::String)
    js = JSON.parsefile(location)
    route = dict_to_solution(js["route"])
    (ins_name, num_node) = split(js["name"], "-")
    problem = load_solomon_data(String(ins_name), num_node=parse(Int64, num_node))
    Solution(route, problem)
end


function load_solution_phase0(ins_name::String)
    pt = "/Users/payakorn/code-julia/Julia/Single-vehicle-Julia/solutions_benchmark/$ins_name.txt"
    f = open(pt)
    lines = readlines(f)
    route = Integer[0]
    for line in lines
        x = parse.(Int64, split(line))
        append!(route, x)
        push!(route, 0)
    end
    close(f)

    problem = load_solomon_data(ins_name, num_node=100)
    return Solution(route, problem)
end


function load_solution_phase1(ins_name::String)
    pt = "/Users/payakorn/code-julia/Julia/Single-vehicle-Julia/phase1_completion_time/phase1/Alg-clustering-heuristic/$ins_name.txt"
    f = open(pt)
    lines = readlines(f)
    route = Integer[0]
    for line in lines
        x = parse.(Int64, split(line))
        append!(route, x)
        push!(route, 0)
    end
    close(f)

    problem = load_solomon_data(ins_name, num_node=100)
    return Solution(route, problem)
end


function load_solution_phase2(ins_name::String)
    pt = "/Users/payakorn/code-julia/Julia/Single-vehicle-Julia/phase1_completion_time/phase1/Alg-clustering-heuristic/move_all_no_update-sort_processing_matrix/$ins_name.txt"
    f = open(pt)
    lines = readlines(f)
    route = Integer[0]
    for line in lines
        x = parse.(Int64, split(line))
        append!(route, x)
        push!(route, 0)
    end
    close(f)

    problem = load_solomon_data(ins_name, num_node=100)
    return Solution(route, problem)
end


function load_solution_phase3(ins_name::String)
    all_ins = glob("*", "/Users/payakorn/code-julia/Julia/Single-vehicle-Julia/phase1_completion_time/phase1/Alg-clustering-heuristic/move_all_no_update-sort_processing_matrix/random_swap_move/$ins_name/")

    problem = load_solomon_data(ins_name, num_node=100)
    min_obj = Inf
    sol = nothing
    for i in all_ins
        f = open(i)
        lines = readlines(f)
        route = Integer[0]
        for line in lines
            x = parse.(Int64, split(line))
            append!(route, x)
            push!(route, 0)
        end
        close(f)
        new_sol = Solution(route, problem)
        if total_comp(new_sol) < min_obj
            min_obj = total_comp(new_sol)
            sol = deepcopy(new_sol)
        end
    end
    return sol
end


function load_solution(ins_name::String, obj_name::String)
    js = JSON.parsefile(dir("data", "opt_solomon", obj_name, "$ins_name.json"))
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
    dis1 = []

    # 2
    balancing2 = []
    total_com2 = []
    solve_time2 = []
    relative_gap2 = []
    dis2 = []

    # 3
    balancing3 = []
    total_com3 = []
    solve_time3 = []
    relative_gap3 = []
    dis3 = []

    # 4
    balancing4 = []
    total_com4 = []
    solve_time4 = []
    relative_gap4 = []
    dis4 = []

    Ins_name, Num_vehicle = list_ins_name()
    for (ins_name) in Ins_name

        @info "reading $ins_name"

        location1 = dir("data", "opt_solomon", "balancing_completion_time", "$ins_name.json")
        location2 = dir("data", "opt_solomon", "total_completion_time", "$ins_name.json")
        location3 = dir("data", "opt_solomon", "total_distance", "$ins_name.json")
        location4 = dir("data", "opt_solomon", "total_distance_compat", "$ins_name.json")
        # if isfile(location1) && isfile(location2)
        js1 = try
            read_opt_json(location1)
        catch e
            nothing
        end
        js2 = try
            read_opt_json(location2)
        catch e
            nothing
        end
        js3 = try
            read_opt_json(location3)
        catch e
            nothing
        end
        js4 = try
            read_opt_json(location4)
        catch e
            nothing
        end

        # add elements
        try
            push!(balancing1, js1["obj_function"])
        catch e
            push!(balancing1, Inf)
        end
        try
            push!(balancing2, js2["obj_function"])
        catch e
            push!(balancing2, Inf)
        end
        try
            push!(balancing3, js3["obj_function"])
        catch e
            push!(balancing3, Inf)
        end
        try
            push!(balancing4, js4["obj_function"])
        catch e
            push!(balancing4, Inf)
        end

        # total completion time
        try
            push!(total_com1, js1["total_com"])
        catch e
            push!(total_com1, Inf)
        end
        try
            push!(total_com2, js2["total_com"])
        catch e
            push!(total_com2, Inf)
        end
        try
            push!(total_com3, js3["total_com"])
        catch e
            push!(total_com3, Inf)
        end
        try
            push!(total_com4, js4["total_com"])
        catch e
            push!(total_com4, Inf)
        end

        # solve time
        try
            push!(solve_time1, js1["solve_time"])
        catch e
            push!(solve_time1, Inf)
        end
        try
            push!(solve_time2, js2["solve_time"])
        catch e
            push!(solve_time2, Inf)
        end
        try
            push!(solve_time3, js3["solve_time"])
        catch e
            push!(solve_time3, Inf)
        end
        try
            push!(solve_time4, js4["solve_time"])
        catch e
            push!(solve_time4, Inf)
        end

        # relative gap
        try
            push!(relative_gap1, js1["relative_gap"])
        catch e
            push!(relative_gap1, 1)
        end
        try
            push!(relative_gap2, js2["relative_gap"])
        catch e
            push!(relative_gap2, 1)
        end
        try
            push!(relative_gap3, js3["relative_gap"])
        catch e
            push!(relative_gap3, 1)
        end
        try
            push!(relative_gap4, js4["relative_gap"])
        catch e
            push!(relative_gap4, 1)
        end

        try
            push!(dis1, distance(load_solution(location1)))
        catch e
            push!(dis1, Inf)
        end
        try
            push!(dis2, distance(load_solution(location2)))
        catch e
            push!(dis2, Inf)
        end
        try
            push!(dis3, distance(load_solution(location3)))
        catch e
            push!(dis3, Inf)
        end
        try
            push!(dis4, distance(load_solution(location4)))
        catch e
            push!(dis4, Inf)
        end
    end

    return DataFrame(
        ins_name=Ins_name,
        num_vehi=Num_vehicle,
        diff_b=balancing1,
        diff_t=balancing2,
        diff_d=balancing3,
        diff_c=balancing4,
        total_b=total_com1,
        total_t=total_com2,
        total_d=total_com3,
        total_c=total_com4,
        dis_b=dis1,
        dis_t=dis2,
        dis_d=dis3,
        dis_c=dis4,
        relative_gap_b=round.(relative_gap1, digits=3),
        relative_gap_t=round.(relative_gap2, digits=3),
        relative_gap_d=round.(relative_gap3, digits=3),
        relative_gap_c=round.(relative_gap4, digits=3),
        solve_time_b=round.(solve_time1, digits=2),
        solve_time_t=round.(solve_time2, digits=2),
        solve_time_d=round.(solve_time3, digits=2),
        solve_time_c=round.(solve_time4, digits=2))
end


function save_simulation_file(df::DataFrame, file_name::String)
    loca = dir("data", "simulations", file_name)
    CSV.write(loca, df)
end


function create_phase_conclusion()
    df = DataFrame(
        ins=ins_names,
        comp0=total_max_comp.(load_solution_phase0.(ins_names)),
        comp1=total_max_comp.(load_solution_phase1.(ins_names)),
        comp2=total_max_comp.(load_solution_phase2.(ins_names)),
        comp3=total_max_comp.(load_solution_phase3.(ins_names)),
        dis0=distance.(load_solution_phase0.(ins_names)),
        dis1=distance.(load_solution_phase1.(ins_names)),
        dis2=distance.(load_solution_phase2.(ins_names)),
        dis3=distance.(load_solution_phase3.(ins_names)),
    )
    CSV.write("data/simulations/phase1phase2phase3.csv", df)
end
