%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from onlydust.stream.generic import generic

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

        let (updated_implicit_args : felt*) = generic.foreach(
            function, array_len, array, element_size, implicit_args_len, implicit_args
        )

        # update implicit arguments
        let implicit_args = cast(updated_implicit_args, foreach_struct.ImplicitArgs*)
        let syscall_ptr = implicit_args.syscall_ptr
        let pedersen_ptr = implicit_args.pedersen_ptr
        let range_check_ptr = implicit_args.range_check_ptr
        return ()
    end

    # The reduce() method executes a "reducer" callback function on each element of the array.
    # The callback function must have this signature exactly (including implicit params):
    #   func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(initial_value : felt, el : felt) -> (res : felt)
    func reduce{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, array_len : felt, array : felt*
    ) -> (res : felt):
        let (res : felt*) = reduce_struct(function, array_len, array, 1)
        return ([res])
    end

    # The reduce_struct() method executes a "reducer" callback function on each element of the array. Unlike reduce(), the array can be an array of structs.
    # The callback function must have this signature exactly (including implicit params):
    #   func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(initial_value : felt*, el : felt*) -> (res : felt*)
    func reduce_struct{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, array_len : felt, array : felt*, element_size : felt
    ) -> (res : felt*):
        # prepare implicit arguments
        let implicit_args_len = reduce_struct.ImplicitArgs.SIZE
        tempvar implicit_args = new reduce_struct.ImplicitArgs(syscall_ptr, pedersen_ptr, range_check_ptr)

        let (res : felt*, updated_implicit_args : felt*) = generic.reduce(
            function, array_len, array, element_size, implicit_args_len, implicit_args
        )

        # update implicit arguments
        let implicit_args = cast(updated_implicit_args, reduce_struct.ImplicitArgs*)
        let syscall_ptr = implicit_args.syscall_ptr
        let pedersen_ptr = implicit_args.pedersen_ptr
        let range_check_ptr = implicit_args.range_check_ptr
        return (res)
    end

    # The filter() method executes a "filtering" callback function on each element of the array and keep only the elements that match.
    # The callback function must have this signature exactly (including implicit params):
    #   func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt) -> (keep : felt)
    func filter{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, array_len : felt, array : felt*
    ) -> (filtered_array_len : felt, filtered_array : felt*):
        return filter_struct(function, array_len, array, 1)
    end

    # The filter_struct() method executes a "filtering" callback function on each element of the array and keep only the elements that match.
    # Unlike filter(), the array can be an array of structs.
    # The callback function must have this signature exactly (including implicit params):
    #   func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt*) -> (keep : felt)
    func filter_struct{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, array_len : felt, array : felt*, element_size : felt
    ) -> (filtered_array_len : felt, filtered_array : felt*):
        # prepare implicit arguments
        let implicit_args_len = filter_struct.ImplicitArgs.SIZE
        tempvar implicit_args = new filter_struct.ImplicitArgs(syscall_ptr, pedersen_ptr, range_check_ptr)

        let (
            filtered_array_len : felt, filtered_array : felt*, updated_implicit_args : felt*
        ) = generic.filter(
            function, array_len, array, element_size, implicit_args_len, implicit_args
        )

        # update implicit arguments
        let implicit_args = cast(updated_implicit_args, filter_struct.ImplicitArgs*)
        let syscall_ptr = implicit_args.syscall_ptr
        let pedersen_ptr = implicit_args.pedersen_ptr
        let range_check_ptr = implicit_args.range_check_ptr

        return (filtered_array_len, filtered_array)
    end

    # The map() method executes a "mapping" callback function on each element of the array and store the returned value in-place of the processed element.
    # The callback function must have this signature exactly (including implicit params):
    #   func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(value : felt) -> (result : felt)
    func map{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, array_len : felt, array : felt*
    ) -> (mapped_array : felt*):
        return map_struct(function, array_len, array, 1)
    end

    # The map_struct() method executes a "mapping" callback function on each element of the array and store the returned value in-place of the processed element.
    # Unlike map(), the array can be an array of structs.
    # The callback function must have this signature exactly (including implicit params):
    #    func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(value : Foo*) -> (result : Foo*)
    func map_struct{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, array_len : felt, array : felt*, element_size : felt
    ) -> (mapped_array : felt*):
        # prepare implicit arguments
        let implicit_args_len = map_struct.ImplicitArgs.SIZE
        tempvar implicit_args = new map_struct.ImplicitArgs(syscall_ptr, pedersen_ptr, range_check_ptr)

        let (mapped_array : felt*, updated_implicit_args : felt*) = generic.map(
            function, array_len, array, element_size, implicit_args_len, implicit_args
        )

        # update implicit arguments
        let implicit_args = cast(updated_implicit_args, map_struct.ImplicitArgs*)
        let syscall_ptr = implicit_args.syscall_ptr
        let pedersen_ptr = implicit_args.pedersen_ptr
        let range_check_ptr = implicit_args.range_check_ptr

        return (mapped_array)
    end

    # The some() method executes a function on each element and returns true if any element on the array returns true.
    # The callback function must have this signature exactly (including implicit params):
    #   func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(index : felt, el : felt) -> (res : felt)
    func some{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, array_len : felt, array : felt*
    ) -> (res : felt):
        let (res : felt) = some_struct(function, array_len, array, 1)
        return (res)
    end

    # The some_struct() method executes a function on each element and returns true if any element on the array returns true. Unlike some(), the array can be an array of structs.
    # The callback function must have this signature exactly (including implicit params):
    #   func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(index : felt*, el : felt*) -> (res : felt*)
    func some_struct{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, array_len : felt, array : felt*, element_size : felt
    ) -> (res : felt):
        # prepare implicit arguments
        let implicit_args_len = some_struct.ImplicitArgs.SIZE
        tempvar implicit_args = new some_struct.ImplicitArgs(syscall_ptr, pedersen_ptr, range_check_ptr)

        let (res : felt, updated_implicit_args : felt*) = generic.some(
            function, array_len, array, element_size, implicit_args_len, implicit_args
        )

        # update implicit arguments
        let implicit_args = cast(updated_implicit_args, some_struct.ImplicitArgs*)
        let syscall_ptr = implicit_args.syscall_ptr
        let pedersen_ptr = implicit_args.pedersen_ptr
        let range_check_ptr = implicit_args.range_check_ptr
        return (res)
    end
end
