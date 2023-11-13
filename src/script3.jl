using VRPTW
# using Gurobi
using Dates


@info "Test"

# VRPTW.find_opt(
#     Gurobi, 
#     obj_func=VRPTW.balancing_value_weighted_sum_w10_w0,
#     time_solve=36000,
#     fix_run=nothing, 
#     customize_num=false
# )