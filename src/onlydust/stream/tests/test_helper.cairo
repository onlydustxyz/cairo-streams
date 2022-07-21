%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

func sum_from_another_file{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    initial_value : felt, el : felt
) -> (res : felt):
    let res = initial_value + el
    return (res)
end

func is_one_from_another_file{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    index : felt, el : felt
) -> (res : felt):
    if el == 1:
        return (1)
    end
    return (0)
end

namespace my_namespace:
    func sum_from_another_namespace{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(initial_value : felt, el : felt) -> (res : felt):
        let res = initial_value + el
        return (res)
    end

    func is_one_from_another_namespace{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(index : felt, el : felt) -> (res : felt):
        if el == 1:
            return (1)
        end
        return (0)
    end
end
