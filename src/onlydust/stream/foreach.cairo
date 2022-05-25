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
    #   - implicit_params_len: length of implicit arguments array
    #   - implicit_params: implicit arguments array
    # Returns:
    #   - array of updated implicit arguments
    func foreach(
        function : codeoffset,
        array_len : felt,
        array : felt*,
        element_size : felt,
        implicit_params_len : felt,
        implicit_params : felt*,
    ) -> (implicit_params : felt*):
        let (func_pc) = get_label_location(function)
        return internal.foreach_loop(
            func_pc, array_len, array, 0, element_size, implicit_params_len, implicit_params
        )
    end
end

namespace internal:
    func foreach_loop(
        func_pc : felt,
        array_len : felt,
        array : felt*,
        index : felt,
        element_size : felt,
        implicit_params_len : felt,
        implicit_params : felt*,
    ) -> (implicit_params : felt*):
        alloc_locals
        if index == array_len:
            return (implicit_params)
        end

        # Put function arguments in appropriate memory cells
        let (local args : felt*) = alloc()
        memcpy(args, implicit_params, implicit_params_len)
        assert args[implicit_params_len] = index
        assert args[implicit_params_len + 1] = cast(array, felt)

        # Call the function
        invoke(func_pc, implicit_params_len + 2, args)

        # Update implicit parameters
        let (ap_val) = get_ap()
        let implicit_params : felt* = cast(ap_val - implicit_params_len, felt*)

        # Process next element
        return foreach_loop(
            func_pc,
            array_len,
            array + element_size,
            index + 1,
            element_size,
            implicit_params_len,
            implicit_params,
        )
    end
end
