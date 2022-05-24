%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin

from starkware.cairo.common.registers import get_label_location
from onlydust.stream.internal.foreach import foreach_internal
from onlydust.stream.internal.reduce import reduce_internal
from onlydust.stream.internal.filter import filter_internal

namespace stream:
    # The foreach() method executes a provided function once for each array element.
    # The provided function must have this signature:
    #   func whatever(el : felt*)
    func foreach{implicit_params : felt*, implicit_params_len : felt}(
        function : codeoffset, array_len : felt, array : felt*, element_size : felt
    ):
        let (func_pc) = get_label_location(function)
        let (updated_implicit_params : felt*) = foreach_internal.custom_implicits.foreach_loop(
            func_pc, array_len, array, 0, element_size, implicit_params_len, implicit_params
        )
        let implicit_params = updated_implicit_params
        return ()
    end

    func update_3_builtins{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, implicit_params : felt*
    }():
        let syscall_ptr = cast(implicit_params[0], felt*)
        let pedersen_ptr = cast(implicit_params[1], HashBuiltin*)
        let range_check_ptr = implicit_params[2]
        return ()
    end

    func update_4_builtins{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
        bitwise_ptr : BitwiseBuiltin*,
        implicit_params : felt*,
    }():
        let syscall_ptr = cast(implicit_params[0], felt*)
        let pedersen_ptr = cast(implicit_params[1], HashBuiltin*)
        let range_check_ptr = implicit_params[2]
        let bitwise_ptr : BitwiseBuiltin* = cast(implicit_params[3], BitwiseBuiltin*)
        return ()
    end
end
