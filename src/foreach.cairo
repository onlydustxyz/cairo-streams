%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_label_location

# The foreach() method executes a provided function once for each array element.
# The provided function must have this signature exactly (including implicit params): func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt)
func foreach{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    func_label_value : codeoffset, array_len : felt, array : felt*
):
    let (func_pc) = get_label_location(func_label_value)
    foreach_loop(func_pc, array_len, array)
    return ()
end

func foreach_loop{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    func_pc, array_len : felt, array : felt*
):
    if array_len == 0:
        return ()
    end
    let el = array[0]

    # Put function arguments in appropriate memory cells
    [ap] = syscall_ptr; ap++
    [ap] = pedersen_ptr; ap++
    [ap] = range_check_ptr; ap++
    [ap] = el; ap++

    # Call the function
    call abs func_pc

    # Update implicit parameters
    let syscall_ptr : felt* = cast([ap - 3], felt*)
    let pedersen_ptr : HashBuiltin* = cast([ap - 2], HashBuiltin*)
    let range_check_ptr = [ap - 1]

    # Process next element
    foreach_loop(func_pc, array_len - 1, array + 1)
    return ()
end
