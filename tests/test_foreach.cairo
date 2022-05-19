%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc
from src.foreach import foreach

@storage_var
func counter() -> (count : felt):
end

@view
func test_foreach{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 1
    assert array[1] = 1
    assert array[2] = 1
    assert array[3] = 7

    let inc_counter_pc = 0
    inc_counter{pc=inc_counter_pc}(0)

    foreach(inc_counter_pc, 4, array)

    let (count) = counter.read()
    assert count = 10

    return ()
end

func inc_counter{pc, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt):
    let (_, pc) = get_fp_and_pc()

    let (count) = counter.read()
    counter.write(count + el)
    return ()
end
