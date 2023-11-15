using VRPTW
using Gurobi
using Dates


@info "Test"

VRPTW.find_opt(
    Gurobi, 
    obj_func=VRPTW.opt_balancing_weighted_sum_w1_w9,
    time_solve=36000,
    fix_run=nothing, 
    customize_num=false
)