%lang starknet

from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.registers import get_ap
from starkware.cairo.common.invoke import invoke
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from onlydust.stream.internal.common import prepare_argument, retrieve_result, new_zero_value

# Should return a boolean
func some_loop(
    func_pc : felt*,
    array_len : felt,
    array : felt*,
    element_size : felt,
    implicit_args_len : felt,
    implicit_args : felt*,
    has_matched : felt,
) -> (res : felt, implicit_args : felt*):
    if has_matched == TRUE:
        return (has_matched, implicit_args)
    end

    if array_len == 0:
        return (has_matched, implicit_args)
    end

    # Build arguments array
    let (args_len : felt, args : felt*) = prepare_arguments(
        array, element_size, implicit_args_len, implicit_args, has_matched
    )

    # Call the function
    invoke(func_pc, args_len, args)

    # Retrieve results
    let (ap_val) = get_ap()
    let implicit_args : felt* = cast(ap_val - implicit_args_len - 1, felt*)
    let res_pointer : felt* = retrieve_result(ap_val, 1)
    let res : felt = [res_pointer]

    # Process next element
    return some_loop(
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
    has_matched : felt,
) -> (args_len : felt, args : felt*):
    alloc_locals

    let (arg_next_element) = prepare_argument(array, element_size)

    let (local args : felt*) = alloc()
    memcpy(args, implicit_args, implicit_args_len)
    assert args[implicit_args_len] = has_matched
    assert args[implicit_args_len + 1] = arg_next_element

    return (implicit_args_len + 2, args)
end
