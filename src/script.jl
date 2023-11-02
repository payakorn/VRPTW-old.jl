using VRPTW
using Dates

date_now = now()
println("start program $(Dates.format(date_now, "e, d u yyyy H:M:S"))")

println("number of Threads: $(Threads.nthreads())")

# Simulated Annealing 
for i in [100]
    
    simulated_annealing_run(obj_func=VRPTW.balancing_value_weighted_sum_w10_w0, num_node=i)
    date_finish = now()
    println("end program W10-0: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")
    
    simulated_annealing_run(obj_func=VRPTW.balancing_value_weighted_sum_w9_w1, num_node=i)
    date_finish = now()
    println("end program W9-1: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")
    
    simulated_annealing_run(obj_func=VRPTW.balancing_value_weighted_sum_w8_w2, num_node=i)
    date_finish = now()
    println("end program W8-2: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")
    
    simulated_annealing_run(obj_func=VRPTW.balancing_value_weighted_sum_w7_w3, num_node=i)
    date_finish = now()
    println("end program W7-3: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")

    simulated_annealing_run(obj_func=VRPTW.balancing_value_weighted_sum_w6_w4, num_node=i)
    date_finish = now()
    println("end program W6-4: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")
    
    simulated_annealing_run(obj_func=VRPTW.balancing_value_weighted_sum_w5_w5, num_node=i)
    date_finish = now()
    println("end program W5-5: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")

    simulated_annealing_run(obj_func=VRPTW.balancing_value_weighted_sum_w4_w6, num_node=i)
    date_finish = now()
    println("end program W4-6: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")

    simulated_annealing_run(obj_func=VRPTW.balancing_value_weighted_sum_w3_w7, num_node=i)
    date_finish = now()
    println("end program W3-7: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")

    simulated_annealing_run(obj_func=VRPTW.balancing_value_weighted_sum_w2_w8, num_node=i)
    date_finish = now()
    println("end program W2-8: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")

    simulated_annealing_run(obj_func=VRPTW.balancing_value_weighted_sum_w1_w9, num_node=i)
    date_finish = now()
    println("end program W1-9: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")

    simulated_annealing_run(obj_func=VRPTW.balancing_value_weighted_sum_w0_w10, num_node=i)
    date_finish = now()
    println("end program W0-10: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")
end

# # find_opt(Gurobi, obj_func=VRPTW.opt_balancing_weighted_sum_w1_w9, time_solve=40000)


date_finish = now()
println("End Time: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")