# using CPLEX

function opt_balancing(ins_name::String, num_vehicle::Integer, solver; time_solve=3600)

    # ins = load_solomon_data(ins_name, num_node = num_vehicle)

    data = load(dir("data", "solomon_jld2", "$(lowercase(ins_name)).jld2"))
    d = data["upper"]
    low_d = data["lower"]
    demand = data["demand"]
    solomon_demand = data["capacity"]
    distance_matrix = data["distance_matrix"]
    service = data["service"]

    # number of node
    n = length(d) - 1

    m = Model(solver.Optimizer)
    set_time_limit_sec(m, time_solve)
    # set_optimizer_attribute(m, "logLevel", 1)

    # num_vehicle = 3
    K = 1:num_vehicle
    M = n * 1000


    # test round distance (some papers truncate digits)
    distance_matrix = floor.(distance_matrix, digits=1)

    # add variables
    @variable(m, x[i=0:n, j=0:n, k=K; i != j], Bin)
    @variable(m, low_d[i+1] <= t[i=0:n] <= d[i+1])

    # new variables: CMAX_i = max completion time of vehicle i
    #               CM_ij = |CMAX_i - CMAX_j|
    @variable(m, 0 <= CMAX[i=K])
    @variable(m, 0 <= CM[i=K, j=K; i < j])


    # add waiting time 
    @variable(m, w[i=0:n], Bin)


    for k in K
        @constraint(m, sum(x[0, j, k] for j in 1:n) == 1)
        @constraint(m, sum(x[i, 0, k] for i in 1:n) == 1)

    end

    # one vehicle in and out each node
    for i = 1:n
        @constraint(m, sum(x[j, i, k] for j in 0:n for k in K if i != j) == 1)
        @constraint(m, sum(x[i, j, k] for j in 0:n for k in K if i != j) == 1)
    end

    # continuity
    for j in 1:n
        for k in K
            @constraint(m, sum(x[i, j, k] for i in 0:n if i != j) - sum(x[j, l, k] for l in 0:n if j != l) == 0)
        end
    end

    # time windows
    for k in K
        # fix(t[0,k], 0, force=true)
        for j in 1:n
            @constraint(m, distance_matrix[1, j+1] <= t[j] + M * (1 - x[0, j, k]) + M * w[j])
            @constraint(m, distance_matrix[1, j+1] >= t[j] - M * (1 - x[0, j, k]) - M * w[j])
        end
    end

    for i in 1:n
        for j in 0:n
            if i != j
                for k in K

                    @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] - M * (1 - x[i, j, k]) <= t[j])

                    # 
                    @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] - M * (1 - x[i, j, k]) - M * w[j] <= t[j])
                    @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] + M * (1 - x[i, j, k]) + M * w[j] >= t[j])
                end
            end
        end
    end

    # waiting time constraints
    for i in 1:n
        @constraint(m, t[i] - M * (1 - w[i]) <= low_d[i+1])
        @constraint(m, low_d[i+1] <= t[i] + M * (1 - w[i]))
    end


    # subtour elimination constraints
    @variable(m, demand[i+1] <= u[i=1:n] <= solomon_demand)
    for i in 1:n
        for j in 1:n
            for k in K
                if i != j
                    @constraint(m, u[i] - u[j] + demand[j+1] <= solomon_demand * (1 - x[i, j, k]))
                end
            end
        end
    end

    # C max constraints: the max completion time is equal to the completion time of the last visit
    for i in 1:n
        for k in K
            @constraint(m, t[i] + service[i+1] + M * (1 - x[i, 0, k]) >= CMAX[k])
            @constraint(m, t[i] + service[i+1] - M * (1 - x[i, 0, k]) <= CMAX[k])
        end
    end

    # the different between two max completion time of two vehicles
    for i in K
        for j in K
            if i < j
                @constraint(m, CMAX[i] - CMAX[j] <= CM[i, j])
                @constraint(m, CMAX[j] - CMAX[i] <= CM[i, j])
            end
        end
    end

    # objective to minimize the total different of max completion time of all vehicles
    @objective(m, Min, sum(CM[i, j] for i in K for j in K if i < j))

    optimize!(m)
    return m, x, t, CMAX, service
end


function opt_total_com(ins_name::String, num_vehicle::Integer, solver; time_solve=3600)

    data = load(dir("data", "solomon_jld2", "$(lowercase(ins_name)).jld2"))
    d = data["upper"]
    low_d = data["lower"]
    demand = data["demand"]
    solomon_demand = data["capacity"]
    distance_matrix = data["distance_matrix"]
    service = data["service"]

    # number of node
    n = length(d) - 1

    m = Model(solver.Optimizer)
    set_time_limit_sec(m, time_solve)
    # set_optimizer_attribute(m, "logLevel", 1)

    # num_vehicle = 3
    K = 1:num_vehicle
    M = n * 1000


    # test round distance (some papers truncate digits)
    distance_matrix = floor.(distance_matrix, digits=1)

    # add variables
    @variable(m, x[i=0:n, j=0:n, k=K; i != j], Bin)
    @variable(m, low_d[i+1] <= t[i=0:n] <= d[i+1])

    @variable(m, 0 <= C[i=1:n])


    for k in K
        @constraint(m, sum(x[0, j, k] for j in 1:n) == 1)
        @constraint(m, sum(x[i, 0, k] for i in 1:n) == 1)

    end


    # # add new 
    # for j in 1:n
    #     @constraint(m, sum(x[i, j, k] for i in 1:n for k in K if i != j) == 1)
    # end


    # one vehicle in and out each node
    for i = 1:n
        @constraint(m, sum(x[j, i, k] for j in 0:n for k in K if i != j) == 1)
        @constraint(m, sum(x[i, j, k] for j in 0:n for k in K if i != j) == 1)
    end

    # continuity
    for j in 1:n
        for k in K
            @constraint(m, sum(x[i, j, k] for i in 0:n if i != j) - sum(x[j, l, k] for l in 0:n if j != l) == 0)
        end
    end

    # # time windows
    # for k in K
    #     # fix(t[0,k], 0, force=true)
    #     for j in 1:n
    #         @constraint(m, distance_matrix[1, j+1] <= t[j]+ M*(1-x[0, j, k]) + M*w[j])
    #         # @constraint(m, distance_matrix[1, j+1] >= t[j]- M*(1-x[0, j, k]) - M*w[j])
    #     end
    # end

    for i in 1:n
        for j in 0:n
            if i != j
                for k in K

                    @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] - M * (1 - x[i, j, k]) <= t[j])


                    # 
                    # @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] - M*(1-x[i, j, k]) - M*w[j] <= t[j] )
                    # @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] + M*(1-x[i, j, k]) + M*w[j] >= t[j] )
                end
            end
        end
    end

    # completion time constraints
    for i in 1:n
        @constraint(m, t[i] + service[i+1] <= C[i])
    end


    # subtour elimination constraints
    @variable(m, demand[i+1] <= u[i=1:n] <= solomon_demand)
    for i in 1:n
        for j in 1:n
            for k in K
                if i != j
                    @constraint(m, u[i] - u[j] + demand[j+1] <= solomon_demand * (1 - x[i, j, k]))
                end
            end
        end
    end


    # objective to minimize the total different of max completion time of all vehicles
    @objective(m, Min, sum(C[i] for i in 1:n))

    optimize!(m)
    return m, x, t, C, service
end


function opt_total_dis(ins_name::String, num_vehicle::Integer, solver; time_solve=3600)

    data = load(dir("data", "solomon_jld2", "$(lowercase(ins_name)).jld2"))
    d = data["upper"]
    low_d = data["lower"]
    demand = data["demand"]
    solomon_demand = data["capacity"]
    distance_matrix = data["distance_matrix"]
    service = data["service"]

    # number of node
    n = length(d) - 1

    m = Model(solver.Optimizer)
    set_time_limit_sec(m, time_solve)
    # set_optimizer_attribute(m, "logLevel", 1)

    # num_vehicle = 3
    K = 1:num_vehicle
    M = n * 1000


    # test round distance (some papers truncate digits)
    distance_matrix = floor.(distance_matrix, digits=1)

    # add variables
    @variable(m, x[i=0:n, j=0:n, k=K; i != j], Bin)
    @variable(m, low_d[i+1] <= t[i=0:n] <= d[i+1])

    # @variable(m, 0 <= C[i=1:n])


    for k in K
        @constraint(m, sum(x[0, j, k] for j in 1:n) == 1)
        @constraint(m, sum(x[i, 0, k] for i in 1:n) == 1)

    end


    # # add new 
    # for j in 1:n
    #     @constraint(m, sum(x[i, j, k] for i in 1:n for k in K if i != j) == 1)
    # end


    # one vehicle in and out each node
    for i = 1:n
        @constraint(m, sum(x[j, i, k] for j in 0:n for k in K if i != j) == 1)
        @constraint(m, sum(x[i, j, k] for j in 0:n for k in K if i != j) == 1)
    end

    # continuity
    for j in 1:n
        for k in K
            @constraint(m, sum(x[i, j, k] for i in 0:n if i != j) - sum(x[j, l, k] for l in 0:n if j != l) == 0)
        end
    end

    # # time windows
    # for k in K
    #     # fix(t[0,k], 0, force=true)
    #     for j in 1:n
    #         @constraint(m, distance_matrix[1, j+1] <= t[j]+ M*(1-x[0, j, k]) + M*w[j])
    #         # @constraint(m, distance_matrix[1, j+1] >= t[j]- M*(1-x[0, j, k]) - M*w[j])
    #     end
    # end

    for i in 1:n
        for j in 0:n
            if i != j
                for k in K

                    @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] - M * (1 - x[i, j, k]) <= t[j])


                    # 
                    # @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] - M*(1-x[i, j, k]) - M*w[j] <= t[j] )
                    # @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] + M*(1-x[i, j, k]) + M*w[j] >= t[j] )
                end
            end
        end
    end

    # # completion time constraints
    # for i in 1:n
    #     @constraint(m, t[i] + service[i+1] <= C[i])
    # end


    # subtour elimination constraints
    @variable(m, demand[i+1] <= u[i=1:n] <= solomon_demand)
    for i in 1:n
        for j in 1:n
            for k in K
                if i != j
                    @constraint(m, u[i] - u[j] + demand[j+1] <= solomon_demand * (1 - x[i, j, k]))
                end
            end
        end
    end


    # objective to minimize the total different of max completion time of all vehicles
    @objective(m, Min, sum(distance_matrix[i+1, j+1] * x[i, j, k] for i in 0:n for j in 0:n for k in K if i != j))

    optimize!(m)
    return m, x, t, nothing, service
end


function opt_total_dis_compat(ins_name::String, num_vehicle::Integer, solver; time_solve=3600)

    data = load(dir("data", "solomon_jld2", "$(lowercase(ins_name)).jld2"))
    d = data["upper"]
    low_d = data["lower"]
    demand = data["demand"]
    solomon_demand = data["capacity"]
    distance_matrix = data["distance_matrix"]
    service = data["service"]

    # number of node
    n = length(d) - 1

    m = Model(solver.Optimizer)
    set_time_limit_sec(m, time_solve)
    # set_optimizer_attribute(m, "logLevel", 1)

    # num_vehicle = 3
    K = 1:num_vehicle
    M = n * 1000

    Q = compat_matrix(n)


    # test round distance (some papers truncate digits)
    distance_matrix = floor.(distance_matrix, digits=1)

    # add variables
    @variable(m, x[i=0:n, j=0:n, k=K; i != j], Bin)
    @variable(m, low_d[i+1] <= t[i=0:n] <= d[i+1])

    # @variable(m, 0 <= C[i=1:n])


    for k in K
        @constraint(m, sum(x[0, j, k] for j in 1:n) == 1)
        @constraint(m, sum(x[i, 0, k] for i in 1:n) == 1)

    end

    # conpatibility constraint
    for j in 1:n
        for k in K
            @constraint(m, sum(x[i, j, k] for i in 0:n if i != j) <= Q[k, j])
        end
    end

    # # add new 
    # for j in 1:n
    #     @constraint(m, sum(x[i, j, k] for i in 1:n for k in K if i != j) == 1)
    # end


    # one vehicle in and out each node
    for i = 1:n
        @constraint(m, sum(x[j, i, k] for j in 0:n for k in K if i != j) == 1)
        @constraint(m, sum(x[i, j, k] for j in 0:n for k in K if i != j) == 1)
    end

    # continuity
    for j in 1:n
        for k in K
            @constraint(m, sum(x[i, j, k] for i in 0:n if i != j) - sum(x[j, l, k] for l in 0:n if j != l) == 0)
        end
    end

    # # time windows
    # for k in K
    #     # fix(t[0,k], 0, force=true)
    #     for j in 1:n
    #         @constraint(m, distance_matrix[1, j+1] <= t[j]+ M*(1-x[0, j, k]) + M*w[j])
    #         # @constraint(m, distance_matrix[1, j+1] >= t[j]- M*(1-x[0, j, k]) - M*w[j])
    #     end
    # end

    for i in 1:n
        for j in 0:n
            if i != j
                for k in K

                    @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] - M * (1 - x[i, j, k]) <= t[j])


                    # 
                    # @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] - M*(1-x[i, j, k]) - M*w[j] <= t[j] )
                    # @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] + M*(1-x[i, j, k]) + M*w[j] >= t[j] )
                end
            end
        end
    end

    # # completion time constraints
    # for i in 1:n
    #     @constraint(m, t[i] + service[i+1] <= C[i])
    # end


    # subtour elimination constraints
    @variable(m, demand[i+1] <= u[i=1:n] <= solomon_demand)
    for i in 1:n
        for j in 1:n
            for k in K
                if i != j
                    @constraint(m, u[i] - u[j] + demand[j+1] <= solomon_demand * (1 - x[i, j, k]))
                end
            end
        end
    end


    # objective to minimize the total different of max completion time of all vehicles
    @objective(m, Min, sum(distance_matrix[i+1, j+1] * x[i, j, k] for i in 0:n for j in 0:n for k in K if i != j))

    optimize!(m)
    return m, x, t, nothing, service
end


function compat_matrix(n::Integer)
    if n == 25
        return [
            1.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0 0.0;
            1.0 1.0 0.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0;
            1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0 1.0 1.0 1.0 0.0 0.0;
            1.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 0.0 1.0 1.0 0.0 1.0 1.0 0.0 0.0 1.0 1.0 1.0 1.0 1.0;
            1.0 1.0 0.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0 0.0 1.0 0.0 1.0 0.0;
            0.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0 1.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 0.0;
            1.0 1.0 0.0 0.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0 0.0 0.0 1.0 1.0 1.0 0.0 1.0 1.0;
            1.0 1.0 0.0 0.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0 0.0 0.0 1.0 1.0 1.0 0.0 1.0 1.0;
        ]
    elseif n == 50
        return [
            0.0 1.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0 0.0 0.0 1.0 0.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 0.0 1.0 0.0 1.0 1.0 0.0 1.0 0.0 1.0 0.0 0.0 1.0 1.0 0.0 0.0 0.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0;
            1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 0.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 0.0 0.0 1.0 1.0 0.0 0.0 0.0 1.0 0.0 0.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0;
            0.0 1.0 0.0 1.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 0.0 0.0 1.0 1.0 0.0 1.0 0.0 0.0 0.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0 1.0 0.0 0.0 0.0 0.0 1.0 1.0 0.0 1.0 1.0 0.0 1.0;
            1.0 1.0 1.0 0.0 0.0 0.0 1.0 0.0 1.0 1.0 0.0 1.0 0.0 0.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0 1.0 0.0 1.0 1.0 1.0 1.0;
            0.0 1.0 1.0 0.0 1.0 1.0 1.0 0.0 1.0 0.0 0.0 1.0 1.0 0.0 1.0 0.0 1.0 0.0 0.0 1.0 1.0 1.0 0.0 0.0 1.0 0.0 0.0 1.0 1.0 0.0 1.0 0.0 1.0 0.0 0.0 1.0 0.0 1.0 1.0 0.0 0.0 1.0 1.0 1.0 1.0 0.0 1.0 0.0 0.0 1.0;
            0.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0 1.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 1.0 1.0 1.0 0.0 1.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0 1.0 1.0 0.0 0.0 1.0 1.0 1.0 0.0 1.0 1.0 0.0 1.0 0.0 0.0 1.0;
            1.0 1.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 0.0 0.0 1.0 1.0 0.0 1.0 0.0 0.0 1.0 1.0 1.0 0.0 1.0 1.0 1.0 1.0 0.0 0.0 0.0 0.0 1.0 1.0 1.0 0.0 0.0 1.0 0.0 0.0 1.0 1.0 0.0 0.0 0.0 0.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0;
            0.0 1.0 0.0 1.0 1.0 0.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0 1.0 1.0 0.0 1.0 1.0 0.0 1.0 1.0 1.0 0.0 1.0 1.0 0.0 1.0 1.0 0.0 1.0 0.0 1.0 1.0 1.0 1.0 0.0 0.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0 1.0 0.0 1.0 1.0 1.0 1.0;
            1.0 0.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0 0.0 0.0 0.0 1.0 1.0 0.0 0.0 0.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0 0.0 0.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0;
            0.0 0.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0 0.0 1.0 1.0 0.0 1.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0 0.0 0.0 1.0 0.0 0.0 1.0 0.0 1.0 0.0 1.0 1.0 1.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0;
            1.0 1.0 1.0 0.0 1.0 0.0 1.0 1.0 1.0 1.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0 0.0 0.0 0.0 1.0 0.0 1.0 1.0 1.0 0.0 0.0 1.0 0.0 1.0 1.0 0.0 1.0 1.0 0.0 1.0;
            0.0 0.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0 1.0 1.0 1.0 0.0 0.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 0.0 0.0 0.0 0.0 1.0 1.0 1.0 1.0 0.0 0.0 0.0 0.0 1.0 1.0 1.0 1.0 0.0 0.0 1.0;
        ]
    elseif n == 100
        return nothing
    end
end


function opt_max_com(ins_name::String, num_vehicle::Integer, solver; time_solve=3600)

    data = load(dir("data", "solomon_jld2", "$(lowercase(ins_name)).jld2"))
    d = data["upper"]
    low_d = data["lower"]
    demand = data["demand"]
    solomon_demand = data["capacity"]
    distance_matrix = data["distance_matrix"]
    service = data["service"]

    # number of node
    n = length(d) - 1

    m = Model(solver.Optimizer)
    set_time_limit_sec(m, time_solve)
    # set_optimizer_attribute(m, "logLevel", 1)

    # num_vehicle = 3
    K = 1:num_vehicle
    M = n * 1000


    # test round distance (some papers truncate digits)
    distance_matrix = floor.(distance_matrix, digits=1)

    # add variables
    @variable(m, x[i=0:n, j=0:n, k=K; i != j], Bin)
    @variable(m, low_d[i+1] <= t[i=0:n] <= d[i+1])

    @variable(m, 0 <= CMAX)


    for k in K
        @constraint(m, sum(x[0, j, k] for j in 1:n) == 1)
        @constraint(m, sum(x[i, 0, k] for i in 1:n) == 1)

    end

    # one vehicle in and out each node
    for i = 1:n
        @constraint(m, sum(x[j, i, k] for j in 0:n for k in K if i != j) == 1)
        @constraint(m, sum(x[i, j, k] for j in 0:n for k in K if i != j) == 1)
    end

    # continuity
    for j in 1:n
        for k in K
            @constraint(m, sum(x[i, j, k] for i in 0:n if i != j) - sum(x[j, l, k] for l in 0:n if j != l) == 0)
        end
    end


    # time windows
    for i in 1:n
        for j in 0:n
            if i != j
                for k in K
                    @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] - M * (1 - x[i, j, k]) <= t[j])
                end
            end
        end
    end

    # max completion time constraints
    for i in 1:n
        @constraint(m, t[i] + service[i+1] <= CMAX)
    end


    # subtour elimination constraints
    @variable(m, demand[i+1] <= u[i=1:n] <= solomon_demand)
    for i in 1:n
        for j in 1:n
            for k in K
                if i != j
                    @constraint(m, u[i] - u[j] + demand[j+1] <= solomon_demand * (1 - x[i, j, k]))
                end
            end
        end
    end


    # objective to minimize the total different of max completion time of all vehicles
    @objective(m, Min, CMAX)

    optimize!(m)
    return m, x, t, CMAX, service
end


function find_opt(solver; obj_func=opt_balancing, time_solve=3600, start_stop = nothing)
    NameNumVehicle = CSV.File(dir("data", "solomon_opt_from_web", "Solomon_Name_NumCus_NumVehicle.csv"))
    Ins_name = [String("$(NameNumVehicle[i][1])-$(NameNumVehicle[i][2])") for i in 1:(length(NameNumVehicle))]
    Num_vehicle = [NameNumVehicle[i][3] for i in 1:(length(NameNumVehicle))]

    if !isnothing(start_stop)
        Ins_name = Ins_name[start_stop]
    end

    if obj_func == opt_balancing
        obj_name = "balancing_completion_time"
    elseif obj_func == opt_total_com
        obj_name = "total_completion_time"
    elseif obj_func == opt_max_com
        obj_name = "max_completion_time"
    elseif obj_func == opt_total_dis
        obj_name = "total_distance"
    elseif obj_func == opt_total_dis_compat
        obj_name = "total_distance_compat"
    end

    for (ins_name, num_vehicle) in zip(Ins_name, Num_vehicle)
        # chack the exiting of file
        file_existing = !isfile(dir("data", "opt_solomon", obj_name, "$ins_name.json"))
        if file_existing == false
            if JSON.parsefile(dir("data", "opt_solomon", obj_name, "$ins_name.json"))["tex"] == "no solution" || (JSON.parsefile(dir("data", "opt_solomon", obj_name, "$ins_name.json"))["solve_time"] < time_solve && abs(JSON.parsefile(dir("data", "opt_solomon", obj_name, "$ins_name.json"))["relative_gap"]) > 0)
                nothing
            else
                continue
            end
        end
        # if !file_existing || JSON.parsefile(dir("data", "opt_solomon", obj_name, "$ins_name.json"))["tex"] == "no solution" || (JSON.parsefile(dir("data", "opt_solomon", obj_name, "$ins_name.json"))["solve_time"] < time_solve && abs(JSON.parsefile(dir("data", "opt_solomon", obj_name, "$ins_name.json"))["relative_gap"]) < 1e-1)

        @info "Optimizing $(ins_name) with $(num_vehicle) vehicles!!! --file exiting: $(file_existing)"
        m, x, t, CMAX, service = obj_func(ins_name, num_vehicle, solver, time_solve=time_solve)

        if has_values(m)
            tex, route = show_opt_solution(x, length(t), num_vehicle)
            write_solution(route, ins_name, tex, m, t, CMAX, service, obj_function=obj_name)
        else
            # create dict
            d = Dict("name" => ins_name, "num_vehicle" => num_vehicle, "route" => "nothing", "tex" => "no solution", "max_completion_time" => "Inf", "obj_function" => "Inf", "solve_time" => time_solve, "relative_gap" => 1, "solver_name" => solver, "total_com" => "Inf")

            # save file
            location = dir("data", "opt_solomon", obj_name)
            if !isfile(location)
                mkpath(location)
            end
            # save json file
            open(joinpath(location, "$ins_name.json"), "w") do io
                JSON3.pretty(io, d, JSON3.AlignmentContext(alignment=:Colon, indent=2))
            end
        end
    end
end
