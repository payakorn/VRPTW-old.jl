using VRPTW
# using Gurobi
using Dates

date_now = now()
println("start program $(Dates.format(date_now, "e, d u yyyy H:M:S"))")

println("number of Threads: $(Threads.nthreads())")

# Simulated Annealing 
for i in [50, 100]
    
    simulated_annealing_run(obj_func=VRPTW.distance, num_node=i)
    date_finish = now()
    println("end program distance: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")

    simulated_annealing_run(obj_func=VRPTW.total_comp, num_node=i)
    date_finish = now()
    println("end program total completion time: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")

    simulated_annealing_run(obj_func=VRPTW.total_max_comp, num_node=i)
    date_finish = now()
    println("end program max total completion time: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")

end

# # find_opt(Gurobi, obj_func=VRPTW.opt_balancing_weighted_sum_w1_w9, time_solve=40000)


date_finish = now()
println("End Time: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")