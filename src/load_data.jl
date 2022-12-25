struct Problem
    name::String
    num_node::Integer
    distance::Matrix
    demand::Vector
    lower_time_window::Vector
    upper_time_window::Vector
    depot_time_window::Integer
    service_time::Vector
    vehicle_capacity::Integer
end


function dir()
    splitdir(splitdir(Base.find_package("VRPTW"))[1])[1]
end


function dir(d...)
    d = string.(d)
    joinpath(dir(), d...)
end


function dir_data(class_ins::String, num_node::Integer)
    dir("data", "solomon_jld2", "$(lowercase(class_ins))-$num_node.jld2")
end



function load_solomon_data(class_ins::String; num_node=100)
    @info "loading Solomon $(uppercase(class_ins)) => with number of nodes = $num_node"
    data = load(dir_data(class_ins, num_node))
    return Problem(
        uppercase(class_ins),
        num_node,
        data["distance_matrix"],
        data["demand"],
        data["lower"],
        data["upper"],
        data["last_time_window"],
        data["service"],
        data["capacity"]
    );
end
