%lang starknet

func sum_from_another_file(initial_value : felt, el : felt) -> (res : felt):
    let res = initial_value + el
    return (res)
end

namespace my_namespace:
    func sum_from_another_namespace(initial_value : felt, el : felt) -> (res : felt):
        let res = initial_value + el
        return (res)
    end
end