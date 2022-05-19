%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.registers import get_label_location
from src.foreach import foreach_internal
from src.reduce import reduce_internal

namespace stream:
    # The foreach() method executes a provided function once for each array element.
    # The provided function must have this signature exactly (including implicit params): func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt)
    func foreach{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        func_label_value : codeoffset, array_len : felt, array : felt*
    ):
        let (func_pc) = get_label_location(func_label_value)
        foreach_internal.foreach_loop(func_pc, array_len, array)
        return ()
    end

    # The foreach_struct() method executes a provided function once for each array element. Unlike foreach(), the array can be an array of structs.
    # The provided function must have this signature exactly (including implicit params): func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt*)
    func foreach_struct{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        func_label_value : codeoffset, array_len : felt, array : felt*, element_size : felt
    ):
        let (func_pc) = get_label_location(func_label_value)
        foreach_internal.foreach_struct_loop(func_pc, array_len, array, element_size)
        return ()
    end

    # The reduce() method executes a "reducer" callback function on each element of the array.
    # The callback function must have this signature exactly (including implicit params): func whatever(initial_value : felt, el : felt) -> (res : felt)
    func reduce(func_label_value : codeoffset, array_len : felt, array : felt*) -> (res : felt):
        let (func_pc) = get_label_location(func_label_value)
        return reduce_internal.reduce_loop(func_pc, array_len, array, 0)
    end
end
