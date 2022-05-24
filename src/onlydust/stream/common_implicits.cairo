%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_label_location
from onlydust.stream.internal.foreach import foreach_internal
from onlydust.stream.internal.reduce import reduce_internal
from onlydust.stream.internal.filter import filter_internal

namespace stream:
    # The foreach() method executes a provided function once for each array element.
    # The provided function must have this signature exactly (including implicit params):
    #   func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt*)
    func foreach{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, array_len : felt, array : felt*, element_size : felt
    ):
        let (func_pc) = get_label_location(function)
        foreach_internal.common_implicits.foreach_loop(func_pc, array_len, array, 0, element_size)
        return ()
    end

    # The reduce() method executes a "reducer" callback function on each element of the array.
    # The callback function must have this signature exactly (including implicit params): func whatever(initial_value : felt, el : felt) -> (res : felt)
    func reduce(func_label_value : codeoffset, array_len : felt, array : felt*) -> (res : felt):
        let (func_pc) = get_label_location(func_label_value)
        return reduce_internal.reduce_loop(func_pc, array_len, array, 0)
    end

    # The filter() method executes a "filtering" callback function on each element of the array and keep only the elements that match.
    # The callback function must have this signature exactly (including implicit params): func whatever{range_check_ptr}(initial_value : felt, el : felt) -> (res : felt)
    func filter{range_check_ptr}(
        func_label_value : codeoffset, array_len : felt, array : felt*
    ) -> (filtered_array_len : felt, filtered_array : felt*):
        alloc_locals
        let (func_pc) = get_label_location(func_label_value)
        let (local filtered_array : felt*) = alloc()
        let (filtered_array_len) = filter_internal.filter_loop(
            func_pc, array_len, array, 0, filtered_array
        )
        return (filtered_array_len, filtered_array)
    end
end
