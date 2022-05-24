%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem
from onlydust.stream.common_implicits import stream

@view
func test_filter{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 1
    assert array[1] = 2
    assert array[2] = 8
    assert array[3] = 7

    let (local filtered_array_len : felt, filtered_array : felt*) = stream.filter(
        keep_even, 4, array
    )

    assert filtered_array_len = 2
    assert filtered_array[0] = 2
    assert filtered_array[1] = 8

    return ()
end

func keep_even{range_check_ptr}(el : felt) -> (keep : felt):
    let (_, rest) = unsigned_div_rem(el, 2)
    return (1 - rest)
end
