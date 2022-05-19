%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_label_location
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

    let (inc_counter_func) = get_label_location(inc_counter)

    foreach(inc_counter_func, 4, array)

    let (count) = counter.read()
    assert count = 10

    return ()
end

func inc_counter{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt):
    let (count) = counter.read()
    counter.write(count + el)
    return ()
end
