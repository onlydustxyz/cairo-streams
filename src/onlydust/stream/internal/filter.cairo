%lang starknet

from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.registers import get_ap
from starkware.cairo.common.invoke import invoke
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.alloc import alloc
from onlydust.stream.internal.common import prepare_argument, append_element

func filter_loop(
    func_pc : felt,
    array_len : felt,
    array : felt*,
    element_size : felt,
    implicit_args_len : felt,
    implicit_args : felt*,
    new_array_len : felt,
    new_array : felt*,
) -> (new_array_len : felt, implicit_args : felt*):
    alloc_locals
    if array_len == 0:
        return (new_array_len, implicit_args)
    end

    # Build arguments array
    let (arg_next_element) = prepare_argument(array, element_size)
    let (args_len : felt, args : felt*) = prepare_arguments(
        arg_next_element, implicit_args_len, implicit_args
    )

    # Call the function
    invoke(func_pc, args_len, args)

    # Retrieve results
    let (ap_val) = get_ap()
    let implicit_args : felt* = cast(ap_val - implicit_args_len - 1, felt*)
    let keep : felt = [ap_val - 1]
    with_attr error_message("Expected the filtering callback to return 0 or 1"):
        assert keep * (1 - keep) = 0
    end

    if keep == 1:
        append_element(new_array, arg_next_element, element_size)
    end

    return filter_loop(
        func_pc,
        array_len - 1,
        array + element_size,
        element_size,
        implicit_args_len,
        implicit_args,
        new_array_len + keep,
        new_array + element_size * keep,
    )
end

func prepare_arguments(
    arg_next_element : felt, implicit_args_len : felt, implicit_args : felt*
) -> (args_len : felt, args : felt*):
    alloc_locals

    let (local args : felt*) = alloc()
    memcpy(args, implicit_args, implicit_args_len)
    assert args[implicit_args_len] = arg_next_element

    return (implicit_args_len + 1, args)
end
