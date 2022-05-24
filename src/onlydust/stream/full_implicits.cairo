%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_label_location
from onlydust.stream.internal.foreach import foreach_internal
from onlydust.stream.internal.reduce import reduce_internal
from onlydust.stream.internal.filter import filter_internal

namespace stream:
    # The foreach() method executes a provided function once for each array element.
    # The provided function must have this signature exactly (including implicit params):
    #   func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(el : felt*)
    func foreach{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
        bitwise_ptr : BitwiseBuiltin*,
    }(function : codeoffset, array_len : felt, array : felt*, element_size : felt):
        let (func_pc) = get_label_location(function)
        foreach_internal.full_implicits.foreach_loop(func_pc, array_len, array, 0, element_size)
        return ()
    end
end
