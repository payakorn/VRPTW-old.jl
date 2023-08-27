"""
    mutable struct Solution(route::Array{Integer}, problem::Problem, obj_func::Function)

Solution of Solomon in the struct format 
### Inputs
- route::Array{Integer}
- problem::Problem
- obj_func::Function

### Output
- Solution
"""
mutable struct Solution
    route::Array{Integer}
    problem::Problem
    obj_func::Function
    # check
    Solution(route, problem, obj_function) = route[1] != 0 || route[end] != 0 ? error("This is not a route representation\nmust start with 0 and end with 0\n i.e. [0, 1, 2, 3, 0, 4, 5, 6, 0, 7, 8, 0]") : new(route, problem, obj_function)
    function Solution(route, problem)
        new(fix_route_zero(route), problem, distance)
    end
end

# change display of struct
Base.show(io::IO, solution::Solution) = print(io, txt_route_full(solution))

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

const C1 = ins_names[1:9]
const C2 = ins_names[10:17]
const R1 = ins_names[18:29]
const R2 = ins_names[30:40]
const RC1 = ins_names[41:48]
const RC2 = ins_names[49:56]

"""
    fix_route_zero(route::Array)

in some situation the route may have zero route in the Solution
### Input:
- route 

### Output:
- route
"""
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


function seperate_route_to_array(solution::Solution)
    route = solution.route
    zero_position = findall(x -> x == 0, route)
    result = []
    for i in 1:route_length(solution)
        push!(result, route[(zero_position[i]+1):(zero_position[i+1]-1)])
    end
    return result
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


function print_route(solution::Solution)
    print(txt_route(solution))
end


function txt_route(solution::Solution)
    # println("solution of $(solution.problem.name)")
    sp = length(string(solution.problem.num_node)) + 1
    r = 1
    txt = ""
    # txt *= "route $r: "
    txt *= rpad("route $r:", 9, " ")
    r += 1
    for i in solution.route[2:end-1]
        if i != 0
            # txt *= "$i "
            txt *= lpad("$i", sp, " ")
        else
            # txt *= "\nroute $r: "
            txt *= rpad("\nroute $r:", 9, " ")
            r += 1
        end
    end
    return txt
end


function txt_route_full(solution::Solution)
    return "Solution: $(solution.problem.name) with $(solution.problem.num_node) nodes and $(route_length(solution)) routes, obj_func: $(solution.obj_func)\n$(txt_route(solution))"
end


function write_solution_txt(solution::Solution, location::String)
    open(location, "w") do f
        write(f, txt_route_full(solution))
    end
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


function cross_over(solution::Solution, pos1::Integer, pos2::Integer)

    if abs(pos1 - pos2) <= 1
        return solution
    end

    A = solution.route[1:pos1]
    D = solution.route[pos2:end]

    middle_part = solution.route[pos1+1:pos2-1]
    first_position = findfirst(x -> x == 0, middle_part)
    last_position = findlast(x -> x == 0, middle_part)

    if isnothing(first_position) && isnothing(last_position)
        append!(A, D)
        push!(A, 0)
        append!(A, middle_part)
        push!(A, 0)
        solution.route = A
        # @info "no first and last position"
        return solution
    elseif first_position == last_position
        B = middle_part[1:first_position]
        C = middle_part[last_position:end]
        append!(A, D)
        append!(C, B)
        append!(A, C)
        solution.route = A
        # @info "first == last"
        return solution
    else
        B = middle_part[1:first_position]
        C = middle_part[last_position:end]
        E = middle_part[first_position:last_position]
        append!(A, D)
        append!(C, B)
        append!(C, E)
        append!(A, C)
        solution.route = A
        # @info "first != last"
        return solution
    end

    solution.route[pos1], solution.route[pos2] = solution.route[pos2], solution.route[pos1]
    return Solution(solution.route, solution.problem, solution.obj_func)
end


function move!(solution::Solution, cus::Integer)
    new_sol = deepcopy(solution)
    deleteat!(new_sol.route, findfirst(x -> x == cus, new_sol.route))
    new_sol = inserting(new_sol, cus, new_sol.obj_func)
    if feasibility(new_sol)
        return new_sol
    else
        return solution
    end
end


function moving_procedure(solution::Solution)
    # obj = solution.obj_func
    best_solution = deepcopy(solution)
    all_posoble_position = shuffle(combinations(findall(x -> x != 0, solution.route), 2))
    # all_posoble_position = combinations(findall(x->x!=0, solution.route), 2)
    for (i, cus) in enumerate(shuffle(1:solution.problem.num_node))
        current_solution = deepcopy(best_solution)
        # @info "iteration $i, moving $cus"
        current_solution = move!(current_solution, cus)
        # if feasibility(current_solution) && (obj(current_solution) < obj(best_solution))
        if feasibility(current_solution)
            # @info "new best found"
            # current_solution.obj_value = obj(current_solution)
            best_solution = deepcopy(current_solution)
            return best_solution
        end
    end
    @info "no new best found"
    return best_solution
end

function swapping_procedure(solution::Solution)
    # obj = solution.obj_func
    best_solution = deepcopy(solution)
    all_posoble_position = shuffle(combinations(findall(x -> x != 0, solution.route), 2))
    # all_posoble_position = combinations(findall(x->x!=0, solution.route), 2)
    for (i, position) in enumerate(all_posoble_position)
        current_solution = deepcopy(best_solution)
        # @info "iteration $i, swapping between position $(position[1]) and position $(position[2])"
        current_solution.route[position[1]], current_solution.route[position[2]] = current_solution.route[position[2]], current_solution.route[position[1]]
        # if feasibility(current_solution) && (obj(current_solution) < obj(best_solution))
        if feasibility(current_solution)
            # @info "new best found"
            # current_solution.obj_value = obj(current_solution)
            best_solution = deepcopy(current_solution)
            return best_solution
        end
    end
    @info "no new best found"
    return best_solution
end


function opt_procedure(solution::Solution)
    best_solution = deepcopy(solution)
    all_posoble_position = shuffle(combinations(findall(x -> x != 0, solution.route), 2))
    for (i, position) in enumerate(all_posoble_position)
        current_solution = deepcopy(best_solution)
        current_solution = cross_over(current_solution, position[1], position[2])
        if feasibility(current_solution)
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
        push!(max_com, c - solution.problem.distance[route[k][end-1]+1, 1])
        # push!(max_com, t)
        # push!(max_com, c - solution.problem.distance[route[k][end-1]+1, 1])
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


function balancing_value(sol::Solution)
    vec_max_comp = max_comp(sol)
    total_balacing_value = 0.0
    for (i, j) = combinations(1:length(vec_max_comp), 2)
        total_balacing_value += abs(vec_max_comp[i] - vec_max_comp[j])
    end
    return total_balacing_value
end


function balancing_value_weighted_sum(sol::Solution)
    return balancing_value(sol) + distance(sol)
end


function balancing_value_weighted_sum_w1_w9(sol::Solution)
    w1, w2 = 0.1, 0.9
    return w1 * balancing_value(sol) + w2 * distance(sol)
end


function balancing_value_weighted_sum_w2_w8(sol::Solution)
    w1, w2 = 0.2, 0.8
    return w1 * balancing_value(sol) + w2 * distance(sol)
end


function balancing_value_weighted_sum_w3_w7(sol::Solution)
    w1, w2 = 0.3, 0.7
    return w1 * balancing_value(sol) + w2 * distance(sol)
end


function balancing_value_weighted_sum_w4_w6(sol::Solution)
    w1, w2 = 0.4, 0.6
    return w1 * balancing_value(sol) + w2 * distance(sol)
end


function balancing_value_weighted_sum_w5_w5(sol::Solution)
    w1, w2 = 0.5, 0.5
    return w1 * balancing_value(sol) + w2 * distance(sol)
end


function balancing_value_weighted_sum_w6_w4(sol::Solution)
    w1, w2 = 0.6, 0.4
    return w1 * balancing_value(sol) + w2 * distance(sol)
end


function balancing_value_weighted_sum_w7_w3(sol::Solution)
    w1, w2 = 0.7, 0.3
    return w1 * balancing_value(sol) + w2 * distance(sol)
end


function balancing_value_weighted_sum_w8_w2(sol::Solution)
    w1, w2 = 0.8, 0.2
    return w1 * balancing_value(sol) + w2 * distance(sol)
end


function balancing_value_weighted_sum_w9_w1(sol::Solution)
    w1, w2 = 0.9, 0.1
    return w1 * balancing_value(sol) + w2 * distance(sol)
end


function load_solution(location::String)
    js = JSON.parsefile(location)
    route = dict_to_solution(js["route"])
    (ins_name, num_node) = split(js["name"], "-")
    problem = load_solomon_data(String(ins_name), num_node=parse(Int64, num_node))
    Solution(route, problem)
end

# load benchmark solution 
function load_solution_phase0(ins_name::String; obj_func=distance)
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
    return Solution(route, problem, obj_func)
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
    return Solution(route, problem)
end


function load_solution(ins_name::String, obj_name::Function)
    js = JSON.parsefile(dir("data", "opt_solomon", obj_name, "$ins_name.json"))
    route = dict_to_solution(js["route"])
    (ins_name, num_node) = split(js["name"], "-")
    problem = load_solomon_data(String(ins_name), num_node=parse(Int64, num_node))
    return Solution(route, problem, obj_name)
end


function load_solution_SA(ins_name::String, obj_func::Function, num_node::Integer, num_ins::Integer)
    location = dir("data", "simulated_annealing", "$(obj_func)", "num_node=$num_node", "$(ins_name)-solution", "$(ins_name)-$(num_ins).txt")

    text = readdlm(location, '\t', '\n', skipstart=1)
    text = [split(i, ":")[2] for i in text]
    route = Int[0]
    for a_route in text
        all_nodes = [parse(Int, i) for i in split(a_route)]
        append!(route, all_nodes)
        push!(route, 0)
    end
    solution = Solution(route, load_solomon_data(ins_name, num_node=num_node), obj_func)
    return solution
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


function save_solution_struct(solution::Solution)
    data = Dict("route" => solution.route, "obj_func" => solution.obj_func)
    open("test.json", "w") do f
        JSON3.write(f, solution)
    end
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


function find_best_solution_of_SA(ins_name; obj_func=distance, num_node=100)
    ins_name = uppercase(ins_name)
    location = dir("data", "simulated_annealing", obj_func, "num_node=$num_node", "$ins_name.csv")

    # defind function to calculate
    # func_to = find_average_node_each_route
    func_to = find_min_max_num_node_each_route

    # main
    if isfile(location)
        df = CSV.File(location) |> DataFrame

        # add new column
        diff_route = [func_to(load_solution_SA(ins_name, obj_func, num_node, ind)) for ind in 1:size(df, 1)]
        df[!, :DiffRoute] = diff_route

        # add distance column
        dis = [distance(load_solution_SA(ins_name, obj_func, num_node, ind)) for ind in 1:size(df, 1)]
        df[!, :Dis] = dis

        # remane
        # rename!(df, :i => :name)

        obj_min, ind = findmin(df.obj)
        df[!, :ins] = [ins_name for i in 1:length(df.obj)]
        df[!, :Num_Run] = size(df, 1) * ones(size(df, 1))
        df = select(df, [:ins, :Num_Run, :i, :date, :alpha, :iter, :time, :num_vehi, :obj, :DiffRoute, :Dis])
        dm = df[ind, :]

        return dm
    else
        dm = CSV.File(dir("data", "simulated_annealing", "head_df.csv")) |> DataFrame
        dm[1, 1] = ins_name
        return dm
    end
end


"""
    The function aim to find all solutions from SA of `ins_name`. This is created for finding Pareto front
    
    
    This function is modified from `find_best_solution_of_SA`
"""
function find_all_solutions_of_SA(ins_name::String; obj_func=distance, num_node=100)
    ins_name = uppercase(ins_name)
    location = dir("data", "simulated_annealing", obj_func, "num_node=$num_node", "$ins_name.csv")

    # defind function to calculate
    # func_to = find_average_node_each_route
    func_to = find_min_max_num_node_each_route

    # main
    if isfile(location)
        df = CSV.File(location) |> DataFrame

        # add new column
        diff_route = [func_to(load_solution_SA(ins_name, obj_func, num_node, ind)) for ind in 1:size(df, 1)]
        df[!, :DiffRoute] = diff_route

        # add distance column
        dis = [distance(load_solution_SA(ins_name, obj_func, num_node, ind)) for ind in 1:size(df, 1)]
        df[!, :Dis] = dis

        # add balancing column
        bal = [balancing_value(load_solution_SA(ins_name, obj_func, num_node, ind)) for ind in 1:size(df, 1)]
        df[!, :Bal] = bal

        # remane
        # rename!(df, :i => :name)

        # obj_min, ind = findmin(df.obj)
        # df[!, :ins] = [ins_name for i in 1:length(df.obj)]
        # df[!, :Num_Run] = size(df, 1) * ones(size(df, 1))
        # df = select(df, [:ins, :Num_Run, :i, :date, :alpha, :iter, :time, :num_vehi, :obj, :DiffRoute, :Dis])
        # dm = df[ind, :]

        return df
    else
        dm = CSV.File(dir("data", "simulated_annealing", "head_df.csv")) |> DataFrame
        dm[1, 1] = ins_name
        return dm
    end
end


function find_min_max_num_node_each_route(solution::Solution)
    sep = seperate_route_to_array(solution)
    length_each_route = [length(i) for i in sep]
    min_each = minimum(length_each_route)
    max_each = maximum(length_each_route)
    return min_each, max_each
end


function find_average_node_each_route(solution::Solution)
    sep = seperate_route_to_array(solution)
    length_each_route = [length(i) for i in sep]
    average = sum(length_each_route) / length(length_each_route)
    return round(average, digits=2)
end


function find_difference_min_max_length_each_route(solution::Solution)
    min_length, max_length = find_min_max_num_node_each_route(solution)
    return max_length - min_length
end


function plot_pareto_front(ins_name::String; num_node=25::Integer)

    obj_funcs = [balancing_value_weighted_sum_w1_w9,
        # balancing_value_weighted_sum_w2_w8,
        # balancing_value_weighted_sum_w3_w7,
        # balancing_value_weighted_sum_w4_w6,
        balancing_value_weighted_sum_w5_w5,
        balancing_value_weighted_sum_w6_w4,
        balancing_value_weighted_sum_w7_w3,
    ]

    # plot first solution in all_solutions
    sol = find_all_solutions_of_SA(ins_name; obj_func=obj_funcs[1], num_node=num_node)
    legend_name = "$(obj_funcs[1])"[30:end]
    @info "plot objective function $(obj_funcs[1])"
    p = Plots.scatter(sol.Dis, sol.Bal, label=legend_name, legend=:outertopright, title=uppercase(ins_name))
    xlabel!("Total distance")
    ylabel!("Total diff")

    # plot others
    for obj_func in obj_funcs[2:end]
        @info "plot objective function $(obj_func)"
        sol = find_all_solutions_of_SA(ins_name, obj_func=obj_func, num_node=num_node)
        legend_name = "$(obj_func)"[30:end] # only last 30 characters
        p = Plots.scatter!(sol.Dis, sol.Bal, label=legend_name)
    end
    savefig(p, dir("data", "simulated_annealing", "plot_pareto", "plot_pareto_$(ins_name).pdf"))
end


function plot_pareto(ins_name::String)
    all_solutions = find_all_solutions_of_SA(ins_name, obj_func=obj_func, num_node=num_node)
end


function create_simulated_annealing_summary(; obj_func=distance, num_node=100)
    dg = DataFrame(find_best_solution_of_SA(ins_names[1], obj_func=obj_func, num_node=num_node))

    # defind function to calculate result column
    # func_to = find_average_node_each_route
    func_to = find_min_max_num_node_each_route

    # main
    for ins_name in ins_names[2:end]
        @info "add instance: $ins_name to dataframe"
        df = DataFrame(find_best_solution_of_SA(ins_name, obj_func=obj_func, num_node=num_node))
        append!(dg, df)
    end
    if obj_func == distance && num_node == 100
        best_obj = [obj_func(load_solution_phase0(ins_name)) for ins_name in ins_names]
        best_vehi = [route_length(load_solution_phase0(ins_name)) for ins_name in ins_names]
        diff_num_each_route = [
            try
                func_to(load_solution_phase0(ins_name))
            catch e
                Inf
            end for ins_name in ins_names
        ]
        dis = [
            try
                distance(load_solution_phase0(ins_name))
            catch e
                Inf
            end for ins_name in ins_names
        ]
    else
        best_obj = [
            try
                obj_func(load_solution(ins_name, num_node, obj_func))
            catch e
                Inf
            end for ins_name in ins_names
        ]
        best_vehi = [
            try
                route_length(load_solution(ins_name, num_node, obj_func))
            catch e
                Inf
            end for ins_name in ins_names
        ]
        diff_num_each_route = [
            try
                func_to(load_solution(ins_name, num_node, obj_func))
            catch e
                Inf
            end for ins_name in ins_names
        ]
        dis = [
            try
                distance(load_solution(ins_name, num_node, obj_func))
            catch e
                Inf
            end for ins_name in ins_names
        ]
    end

    # change column name
    dg[!, :BestVehi] = best_vehi
    dg[!, :BestKnown] = best_obj
    dg[!, :BestDiffRoute] = diff_num_each_route
    dg[!, :BestDis] = dis

    # round column gap
    dg = select(dg, :, [:obj, :BestKnown] => (a, b) -> (round.((a .- b) ./ b .* 100, digits=2)))
    rename!(dg, :obj_BestKnown_function => :gap)

    # round degits for columns objective value and best known value
    dg.obj = round.(dg.obj, digits=2)
    dg.BestKnown = round.(dg.BestKnown, digits=2)

    # add new column
    # dg[!, :DiffRouteEach] = diff_num_each_route

    # export to csv
    CSV.write(dir("data", "simulated_annealing", obj_func, "SA_summary_$num_node.csv"), dg)

    return dg
end
