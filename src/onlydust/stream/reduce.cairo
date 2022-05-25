%lang starknet

from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.registers import get_ap
from starkware.cairo.common.invoke import invoke
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.alloc import alloc

namespace generic:
    # The foreach() method executes a provided function once for each array element.
    # Params:
    #   - function: the function to be executed once for each array element.
    #   - array_len: length of the array
    #   - array: the array
    #   - element_size: size of each element in the array
    #   - implicit_args_len: length of implicit arguments array
    #   - implicit_args: implicit arguments array
    # Returns:
    #   - array of updated implicit arguments
    func reduce(
        function : codeoffset,
        array_len : felt,
        array : felt*,
        element_size : felt,
        implicit_args_len : felt,
        implicit_args : felt*,
    ) -> (res : felt, implicit_args : felt*):
        let (func_pc) = get_label_location(function)
        return internal.reduce_loop(
            func_pc, array_len, array, element_size, implicit_args_len, implicit_args, 0
        )
    end
end

namespace internal:
    func reduce_loop(
        func_pc : felt,
        array_len : felt,
        array : felt*,
        element_size : felt,
        implicit_args_len : felt,
        implicit_args : felt*,
        current_value : felt,
    ) -> (res : felt, implicit_args : felt*):
        alloc_locals
        if array_len == 0:
            return (current_value, implicit_args)
        end

        # Put function arguments in appropriate memory cells
        let (arg) = next_element(array, element_size)
        let (local args : felt*) = alloc()
        memcpy(args, implicit_args, implicit_args_len)
        assert args[implicit_args_len] = current_value
        assert args[implicit_args_len + 1] = arg

        # Call the function
        invoke(func_pc, implicit_args_len + 2, args)

        # Update implicit parameters
        let (ap_val) = get_ap()
        let implicit_args : felt* = cast(ap_val - implicit_args_len - 1, felt*)
        let res : felt = [cast(ap_val - 1, felt*)]

        # Process next element
        return reduce_loop(
            func_pc,
            array_len - 1,
            array + element_size,
            element_size,
            implicit_args_len,
            implicit_args,
            res,
        )
    end

    # Returns the next element of the array to be considered
    #    - if element_size == 1, the element is a felt, returns it
    #    - if element_size > 1, the element is a struct, returns the pointer to it
    func next_element(array : felt*, element_size : felt) -> (next : felt):
        if element_size == 1:
            return (next=[array])
        end

        return (next=cast(array, felt))
    end
end
