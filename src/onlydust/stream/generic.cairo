%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import FALSE
from onlydust.stream.internal.foreach import foreach_loop
from onlydust.stream.internal.reduce import reduce_loop
from onlydust.stream.internal.filter import filter_loop
from onlydust.stream.internal.map import map_loop
from onlydust.stream.internal.some import some_loop
from onlydust.stream.internal.common import new_zero_value

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
    func foreach(
        function : codeoffset,
        array_len : felt,
        array : felt*,
        element_size : felt,
        implicit_args_len : felt,
        implicit_args : felt*,
    ) -> (implicit_args : felt*):
        let (func_pc) = get_label_location(function)
        return foreach_loop(
            func_pc, array_len, array, 0, element_size, implicit_args_len, implicit_args
        )
    end

    # The reduce() method executes a "reducer" callback function on each element of the array.
    # The callback function must have this signature: func whatever(initial_value : felt, element : felt) -> (res : felt)
    # Params:
    #   - function: the function to be executed once for each array element.
    #   - array_len: length of the array
    #   - array: the array
    #   - element_size: size of each element in the array
    #   - implicit_args_len: length of implicit arguments array
    #   - implicit_args: implicit arguments array
    # Returns:
    #   - the result, as a felt* (can be casted to a felt or a struct)
    #   - array of updated implicit arguments
    func reduce(
        function : codeoffset,
        array_len : felt,
        array : felt*,
        element_size : felt,
        implicit_args_len : felt,
        implicit_args : felt*,
    ) -> (res : felt*, implicit_args : felt*):
        alloc_locals
        let (local func_pc) = get_label_location(function)
        let (zero_value) = new_zero_value(element_size)
        return reduce_loop(
            func_pc, array_len, array, element_size, implicit_args_len, implicit_args, zero_value
        )
    end

    # The filter() method executes a "filtering" callback function on each element of the array and keep only the elements that match.
    # The callback function must have this signature exactly: func whatever(el : felt) -> (keep : felt)
    # Params:
    #   - function: the function to be executed once for each array element.
    #   - array_len: length of the array
    #   - array: the array
    #   - element_size: size of each element in the array
    #   - implicit_args_len: length of implicit arguments array
    #   - implicit_args: implicit arguments array
    # Returns:
    #   - the filtered array length
    #   - the filtered array
    #   - array of updated implicit arguments
    func filter(
        function : codeoffset,
        array_len : felt,
        array : felt*,
        element_size : felt,
        implicit_args_len : felt,
        implicit_args : felt*,
    ) -> (filtered_array_len : felt, filtered_array : felt*, implicit_args : felt*):
        alloc_locals
        let (local func_pc) = get_label_location(function)
        let (filtered_array : felt*) = alloc()
        let (filtered_array_len : felt, implicit_args : felt*) = filter_loop(
            func_pc,
            array_len,
            array,
            element_size,
            implicit_args_len,
            implicit_args,
            0,
            filtered_array,
        )
        return (filtered_array_len, filtered_array, implicit_args)
    end

    # The map() method executes a "mapping" callback function on each element of the array and store the returned value in-place of the processed element.
    # Params:
    #   - function: the function to be executed once for each array element.
    #   - array_len: length of the array
    #   - array: the array
    #   - element_size: size of each element in the array
    #   - implicit_args_len: length of implicit arguments array
    #   - implicit_args: implicit arguments array
    # Returns:
    #   - the mapped array
    #   - array of updated implicit arguments
    func map(
        function : codeoffset,
        array_len : felt,
        array : felt*,
        element_size : felt,
        implicit_args_len : felt,
        implicit_args : felt*,
    ) -> (mapped_array : felt*, implicit_args : felt*):
        alloc_locals
        let (local func_pc) = get_label_location(function)
        let (mapped_array : felt*) = alloc()
        let (implicit_args : felt*) = map_loop(
            func_pc, array_len, array, element_size, implicit_args_len, implicit_args, mapped_array
        )
        return (mapped_array, implicit_args)
    end

    # The some() method executes a function on each element and returns true if any element on the array returns true.
    # The callback function must have this signature: func whatever(index : felt, element : felt) -> (res : felt)
    # Params:
    #   - function: the function to be used to check each array element.
    #   - array_len: length of the array
    #   - array: the array
    #   - element_size: size of each element in the array
    #   - implicit_args_len: length of implicit arguments array
    #   - implicit_args: implicit arguments array
    # Returns:
    #   - the result, as a felt (it's 1 or 0, true or false)
    #   - array of updated implicit arguments
    func some(
        function : codeoffset,
        array_len : felt,
        array : felt*,
        element_size : felt,
        implicit_args_len : felt,
        implicit_args : felt*,
    ) -> (res : felt, implicit_args : felt*):
        alloc_locals
        let (local func_pc) = get_label_location(function)
        return some_loop(
            func_pc, array_len, array, element_size, implicit_args_len, implicit_args, FALSE
        )
    end
end
