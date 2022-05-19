%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.registers import get_label_location

namespace foreach_internal:
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

    func foreach_struct_loop{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        func_pc : felt, array_len : felt, array : felt*, element_size : felt
    ):
        if array_len == 0:
            return ()
        end

        # Put function arguments in appropriate memory cells
        [ap] = syscall_ptr; ap++
        [ap] = pedersen_ptr; ap++
        [ap] = range_check_ptr; ap++
        [ap] = array; ap++

        # Call the function
        call abs func_pc

        # Update implicit parameters
        let syscall_ptr : felt* = cast([ap - 3], felt*)
        let pedersen_ptr : HashBuiltin* = cast([ap - 2], HashBuiltin*)
        let range_check_ptr = [ap - 1]

        # Process next element
        foreach_struct_loop(func_pc, array_len - 1, array + element_size, element_size)
        return ()
    end
end
