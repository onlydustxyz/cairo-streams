%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.registers import get_label_location

namespace filter_internal:
    func filter_loop{range_check_ptr}(
        func_pc : felt, array_len : felt, array : felt*, new_array_len, new_array : felt*
    ) -> (new_array_len : felt):
        if array_len == 0:
            return (new_array_len)
        end
        let el = array[0]

        # Put function arguments in appropriate memory cells
        [ap] = range_check_ptr; ap++
        [ap] = el; ap++

        # Call the function
        let res = call abs func_pc

        let range_check_ptr = [ap - 2]

        if res == 1:
            assert new_array[new_array_len] = el
            return filter_loop(func_pc, array_len - 1, array + 1, new_array_len + 1, new_array)
        end

        return filter_loop(func_pc, array_len - 1, array + 1, new_array_len, new_array)
    end
end
