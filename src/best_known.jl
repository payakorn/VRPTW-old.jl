function combine_best_known(;num_node=100)
    location = dir("data", "Solomon_best_by_authers", "num_node=$num_node")
    all_authers = glob("*.csv", location)
    dv = [CSV.File(i)|>DataFrame for i in all_authers]
    dm = vcat(dv...)
    dm = combine(dm -> filter(:TD => ==(minimum(dm.TD)), dm), groupby(dm, :Instance))
    df = combine(dm -> filter(:Year => ==(minimum(dm.Year)), dm), groupby(dm, :Instance))
    return df
end

function find_best_known(ins_name::String; num_node=100)
    location = dir("data", "Solomon_best_by_authers", "num_node=$num_node")
    all_authers = glob("*.csv", location)
end

function create_best_known_table(;num_node=100)
    nothing
end