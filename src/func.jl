function my_func(x, y)
    return x + 2y
end

struct VR
    a::Any
    b::Any
    function VR(a, b)
        new(a + 1, b + 1)
    end
end


function setup_test_variables()
    list_eval = (
        :(ins_name = "C101"),
        :(obj_func = distance),
    )
    return list_eval
end
