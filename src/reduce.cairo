%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc

# The reduce() method executes a "reducer" callback function on each element of the array.
# The callback function must have this signature exactly (including implicit params): func whatever(initial_value : felt, el : felt) -> (res : felt)
func reduce(func_pc : felt, array_len : felt, array : felt*) -> (res : felt):
    return reduce_loop(func_pc, array_len, array, 0)
end

func reduce_loop(func_pc : felt, array_len : felt, array : felt*, current_value : felt) -> (
    res : felt
):
    if array_len == 0:
        return (current_value)
    end
    let el = array[0]

    # Put function arguments in appropriate memory cells
    [ap] = current_value; ap++
    [ap] = el; ap++

    # Call the function
    let res = call abs func_pc

    return reduce_loop(func_pc, array_len - 1, array + 1, res)
end
