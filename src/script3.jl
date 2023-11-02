using VRPTW
# using Gurobi
using Dates

date_now = now()

println("start program $(Dates.format(date_now, "e, d u yyyy H:M:S"))")
println("number of Threads: $(Threads.nthreads())")

# sent sent_email

sent_email("test sent from script ERAWAN", "<h1>this is the test</h1>")


date_finish = now()
println("End Time: $(Dates.format(date_now, "e, d u yyyy H:M:S"))")