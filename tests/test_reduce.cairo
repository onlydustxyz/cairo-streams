%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from src.reduce import reduce
from tests.test_helper import sum_from_another_file

@view
func test_reduce{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 1
    assert array[1] = 1
    assert array[2] = 1
    assert array[3] = 7

    let (res) = reduce(sum, 4, array)
    assert res = 10

    return ()
end

func sum(initial_value : felt, el : felt) -> (res : felt):
    let res = initial_value + el
    return (res)
end

@view
func test_reduce_with_sum_from_another_file{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 1
    assert array[1] = 1
    assert array[2] = 1
    assert array[3] = 7

    let (res) = reduce(sum_from_another_file, 4, array)
    assert res = 10

    return ()
end
