%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from onlydust.stream.foreach import generic

# --------------------------------------------------------------------------------------------------------
# This file contains default implementations for foreach, map, reduce and filter functions.
#
# The default implementation expect exactly these implicit arguments in provided functions:
#   {syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}
#
# If you need to pass a different set of implicit arguments, you shall create your own implementation(s)
# inspired by those ones.
# --------------------------------------------------------------------------------------------------------

namespace stream:
    # The foreach() method executes a provided function once for each array element.
    # The provided function must have this signature exactly (including implicit params):
    #   func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt*)
    func foreach{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, array_len : felt, array : felt*
    ):
        foreach_struct(function, array_len, array, 1)
        return ()
    end

    # The foreach_struct() method executes a provided function once for each array element. Unlike foreach(), the array can be an array of structs.
    # The provided function must have this signature exactly (including implicit params):
    #   func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt*)
    func foreach_struct{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, array_len : felt, array : felt*, element_size : felt
    ):
        # prepare implicit arguments
        let implicit_args_len = foreach_struct.ImplicitArgs.SIZE
        tempvar implicit_args = new foreach_struct.ImplicitArgs(syscall_ptr, pedersen_ptr, range_check_ptr)

        # call foreach
        let (updated_implicit_params : felt*) = generic.foreach(
            function, array_len, array, element_size, implicit_args_len, implicit_args
        )

        # update implicit arguments
        let implicit_args = cast(updated_implicit_params, foreach_struct.ImplicitArgs*)
        let syscall_ptr = implicit_args.syscall_ptr
        let pedersen_ptr = implicit_args.pedersen_ptr
        let range_check_ptr = implicit_args.range_check_ptr
        return ()
    end
end