%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.registers import get_label_location

namespace reduce_internal:
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
end
