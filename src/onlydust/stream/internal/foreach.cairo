%lang starknet

from starkware.cairo.common.registers import get_ap
from starkware.cairo.common.invoke import invoke
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.alloc import alloc

func foreach_loop(
    func_pc : felt*,
    array_len : felt,
    array : felt*,
    index : felt,
    element_size : felt,
    implicit_args_len : felt,
    implicit_args : felt*,
) -> (implicit_args : felt*):
    alloc_locals
    if index == array_len:
        return (implicit_args)
    end

    # Build arguments array
    let (args_len : felt, args : felt*) = prepare_arguments(
        array, implicit_args_len, implicit_args, index
    )

    # Call the function
    invoke(func_pc, args_len, args)

    # Update implicit parameters
    let (ap_val) = get_ap()
    let implicit_args : felt* = cast(ap_val - implicit_args_len, felt*)

    # Process next element
    return foreach_loop(
        func_pc,
        array_len,
        array + element_size,
        index + 1,
        element_size,
        implicit_args_len,
        implicit_args,
    )
end

func prepare_arguments(
    array : felt*, implicit_args_len : felt, implicit_args : felt*, index : felt
) -> (args_len : felt, args : felt*):
    alloc_locals

    let (local args : felt*) = alloc()
    memcpy(args, implicit_args, implicit_args_len)
    assert args[implicit_args_len] = index
    assert args[implicit_args_len + 1] = cast(array, felt)

    return (implicit_args_len + 2, args)
end
