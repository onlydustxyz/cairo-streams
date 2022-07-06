%lang starknet

from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.registers import get_ap
from starkware.cairo.common.invoke import invoke
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.alloc import alloc
from onlydust.stream.internal.common import prepare_argument, retrieve_result, new_zero_value

func reduce_loop(
    func_pc : felt*,
    array_len : felt,
    array : felt*,
    element_size : felt,
    implicit_args_len : felt,
    implicit_args : felt*,
    current_value : felt*,
) -> (res : felt*, implicit_args : felt*):
    if array_len == 0:
        return (current_value, implicit_args)
    end

    # Build arguments array
    let (args_len : felt, args : felt*) = prepare_arguments(
        array, element_size, implicit_args_len, implicit_args, current_value
    )

    # Call the function
    invoke(func_pc, args_len, args)

    # Retrieve results
    let (ap_val) = get_ap()
    let implicit_args : felt* = cast(ap_val - implicit_args_len - 1, felt*)
    let (res : felt*) = retrieve_result(ap_val, element_size)

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

func prepare_arguments(
    array : felt*,
    element_size : felt,
    implicit_args_len : felt,
    implicit_args : felt*,
    current_value : felt*,
) -> (args_len : felt, args : felt*):
    alloc_locals

    let (arg_next_element) = prepare_argument(array, element_size)
    let (arg_current_value) = prepare_argument(current_value, element_size)

    let (local args : felt*) = alloc()
    memcpy(args, implicit_args, implicit_args_len)
    assert args[implicit_args_len] = arg_current_value
    assert args[implicit_args_len + 1] = arg_next_element

    return (implicit_args_len + 2, args)
end
