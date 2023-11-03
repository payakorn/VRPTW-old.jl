using VRPTW
# using Gurobi
using Dates

@time Threads.@threads for i in 1:1_000_000
    println("loop $i using threads $(Threads.threadid())")
end