%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from src.foreach import foreach, foreach_struct

@storage_var
func counter() -> (count : felt):
end

@storage_var
func counter_x() -> (count : felt):
end

@storage_var
func counter_y() -> (count : felt):
end

@view
func test_foreach{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 1
    assert array[1] = 1
    assert array[2] = 1
    assert array[3] = 7

    foreach(inc_counter, 4, array)

    let (count) = counter.read()
    assert count = 10

    return ()
end

func inc_counter{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt):
    let (count) = counter.read()
    counter.write(count + el)
    return ()
end

struct Foo:
    member x : felt
    member y : felt
end

@view
func test_foreach_struct{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    let (local array : Foo*) = alloc()
    assert array[0] = Foo(1, 10)
    assert array[1] = Foo(1, 10)
    assert array[2] = Foo(2, 20)
    assert array[3] = Foo(7, 70)

    foreach_struct(inc_counter_foo, 4, array, Foo.SIZE)

    let (count_x) = counter_x.read()
    assert count_x = 11

    let (count_y) = counter_y.read()
    assert count_y = 110

    return ()
end

func inc_counter_foo{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt*):
    let foo : Foo = [cast(el, Foo*)]

    let (count_x) = counter_x.read()
    counter_x.write(count_x + foo.x)

    let (count_y) = counter_y.read()
    counter_y.write(count_y + foo.y)
    return ()
end