%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc
from src.reduce import reduce

@view
func test_reduce{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 1
    assert array[1] = 1
    assert array[2] = 1
    assert array[3] = 7

    let sum_pc = 0
    sum{pc=sum_pc}(0, 0)

    let (res) = reduce(sum_pc, 4, array)
    assert res = 10

    return ()
end

func sum{pc}(initial_value : felt, el : felt) -> (res : felt):
    let (_, pc) = get_fp_and_pc()

    let res = initial_value + el
    return (res)
end
