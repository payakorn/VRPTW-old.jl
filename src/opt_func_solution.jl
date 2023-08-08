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


function write_solution(route::Dict, ins_name::String, tex::String, m, t, CMAX, service; obj_function="balancing_completion_time"::String)

    if obj_function == "balancing_completion_time"
        # check location
        location = dir("data", "opt_solomon", "balancing_completion_time")
        # location = joinpath(@__DIR__, "..", "" "opt_solomon", "$name") 
        if isfile(location) == false
            mkpath(location)
        end

        # calculate max completion time
        max_com = Dict(k => value.(CMAX[k]) for k in 1:(length(route)))

        # total completion time
        total_com = sum([value.(t[i]) + service[i+1] for i in 1:(length(t)-1)])


        # create dict
        d = Dict("name" => ins_name, "num_vehicle" => length(route), "route" => route, "tex" => tex, "max_completion_time" => max_com, "obj_function" => JuMP.objective_value(m), "solve_time" => solve_time(m), "relative_gap" => relative_gap(m), "solver_name" => solver_name(m), "total_com" => total_com)
    elseif obj_function == "balancing_completion_time_weighted_sum"
        # check location
        location = dir("data", "opt_solomon", "balancing_completion_time_weighted_sum")
        # location = joinpath(@__DIR__, "..", "" "opt_solomon", "$name") 
        if isfile(location) == false
            mkpath(location)
        end

        # calculate max completion time
        max_com = Dict(k => value.(CMAX[k]) for k in 1:(length(route)))

        # total completion time
        total_com = sum([value.(t[i]) + service[i+1] for i in 1:(length(t)-1)])


        # create dict
        d = Dict("name" => ins_name, "num_vehicle" => length(route), "route" => route, "tex" => tex, "max_completion_time" => max_com, "obj_function" => JuMP.objective_value(m), "solve_time" => solve_time(m), "relative_gap" => relative_gap(m), "solver_name" => solver_name(m), "total_com" => total_com)
    elseif obj_function == "total_completion_time"
        location = dir("data", "opt_solomon", "total_completion_time")
        # location = joinpath(@__DIR__, "..", "" "opt_solomon", "$name") 
        if isfile(location) == false
            mkpath(location)
        end

        # calculate max completion time
        # max_com = Dict(k => value.(CMAX[route[k][end-1]]) for k in 1:(length(route)))
        max_com = Dict(k => value.(t[route[k][end-1]]) + service[route[k][end-1]+1] for k in 1:(length(route)))
        
        # balancing
        if length(route) == 1
            bc = 0.0
        else
            bc = sum([abs(max_com[i] - max_com[j]) for i in 1:length(route) for j in 1:length(route) if i < j])
        end

        # total completion time
        total_com = sum([value.(t[i]) + service[i+1] for i in 1:(length(t)-1)])

        # create dict
        d = Dict("name" => ins_name, "num_vehicle" => length(route), "route" => route, "tex" => tex, "max_completion_time" => max_com, "obj_function" => bc, "solve_time" => solve_time(m), "relative_gap" => relative_gap(m), "solver_name" => solver_name(m), "total_com" => JuMP.objective_value(m))
    elseif obj_function == "max_completion_time"
        location = dir("data", "opt_solomon", "max_completion_time")
        # location = joinpath(@__DIR__, "..", "" "opt_solomon", "$name") 
        if isfile(location) == false
            mkpath(location)
        end

        # calculate max completion time
        max_com = Dict(k => value.(t[route[k][end-1]]) + service[route[k][end-1]+1] for k in 1:(length(route)))
        # balancing
        bc = sum([abs(value.(t[route[i][end-1]]) - value.(t[route[j][end-1]])) for i in 1:(length(route)) for j in 1:(length(route)) if i < j])

        # total completion time
        total_com = sum([value.(t[i]) + service[i+1] for i in 1:(length(t)-1)])

        # create dict
        d = Dict("name" => ins_name, "num_vehicle" => length(route), "route" => route, "tex" => tex, "max_completion_time" => max_com, "obj_function" => bc, "solve_time" => solve_time(m), "relative_gap" => relative_gap(m), "solver_name" => solver_name(m), "total_com" => total_com)
    elseif obj_function == "total_distance"
        location = dir("data", "opt_solomon", "total_distance")
        # location = joinpath(@__DIR__, "..", "" "opt_solomon", "$name") 
        if isfile(location) == false
            mkpath(location)
        end

        # calculate max completion time
        max_com = Dict(k => value.(t[route[k][end-1]]) + service[route[k][end-1]+1] for k in 1:(length(route)))
        # balancing
        bc = sum([abs(value.(t[route[i][end-1]]) - value.(t[route[j][end-1]])) for i in 1:(length(route)) for j in 1:(length(route)) if i < j])

        # total completion time
        total_com = sum([value.(t[i]) + service[i+1] for i in 1:(length(t)-1)])

        # create dict
        d = Dict("name" => ins_name, "num_vehicle" => length(route), "route" => route, "tex" => tex, "max_completion_time" => max_com, "obj_function" => bc, "solve_time" => solve_time(m), "relative_gap" => relative_gap(m), "solver_name" => solver_name(m), "total_com" => total_com)
    elseif obj_function == "total_distance_compat"
        location = dir("data", "opt_solomon", "total_distance_compat")
        # location = joinpath(@__DIR__, "..", "" "opt_solomon", "$name") 
        if isfile(location) == false
            mkpath(location)
        end

        # calculate max completion time
        max_com = Dict(k => value.(t[route[k][end-1]]) + service[route[k][end-1]+1] for k in 1:(length(route)))
        # balancing
        bc = sum([abs(value.(t[route[i][end-1]]) - value.(t[route[j][end-1]])) for i in 1:(length(route)) for j in 1:(length(route)) if i < j])

        # total completion time
        total_com = sum([value.(t[i]) + service[i+1] for i in 1:(length(t)-1)])

        # create dict
        d = Dict("name" => ins_name, "num_vehicle" => length(route), "route" => route, "tex" => tex, "max_completion_time" => max_com, "obj_function" => bc, "solve_time" => solve_time(m), "relative_gap" => relative_gap(m), "solver_name" => solver_name(m), "total_com" => total_com)
    end


    if isfile(joinpath(location, "$ins_name.json"))
        mkdir(joinpath(location, "$ins_name.json"))
    end
    open(joinpath(location, "$ins_name.json"), "w") do io
        JSON3.pretty(io, d, JSON3.AlignmentContext(alignment=:Colon, indent=2))
    end
end
# 