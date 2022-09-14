%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from onlydust.stream.default_implementation import stream

@view
func test_map{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    let (local array: felt*) = alloc();
    assert array[0] = 1;
    assert array[1] = 2;
    assert array[2] = 3;
    assert array[3] = 4;

    let (array) = stream.map(double, 4, array);

    assert 2 = array[0];
    assert 4 = array[1];
    assert 6 = array[2];
    assert 8 = array[3];

    return ();
}

func double{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(value: felt) -> (
    result: felt
) {
    return (result=value * 2);
}

struct Foo {
    x: felt,
    y: felt,
}

@view
func test_map_struct{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    let (local array: Foo*) = alloc();
    assert array[0] = Foo(1, 10);
    assert array[1] = Foo(2, 20);
    assert array[2] = Foo(3, 30);
    assert array[3] = Foo(4, 40);

    let (local array: Foo*) = stream.map_struct(double_foo, 4, array, Foo.SIZE);

    assert Foo(2, 20) = array[0];
    assert Foo(4, 40) = array[1];
    assert Foo(6, 60) = array[2];
    assert Foo(8, 80) = array[3];

    return ();
}

func double_foo{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(foo: Foo*) -> (
    result: Foo*
) {
    return (new Foo(foo.x * 2, foo.y * 2),);
}
