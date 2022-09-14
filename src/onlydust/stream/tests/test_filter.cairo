%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem
from onlydust.stream.default_implementation import stream

@view
func test_filter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    let (local array: felt*) = alloc();
    assert array[0] = 1;
    assert array[1] = 2;
    assert array[2] = 8;
    assert array[3] = 7;

    let (local filtered_array_len: felt, filtered_array: felt*) = stream.filter(
        keep_even, 4, array
    );

    assert 2 = filtered_array_len;
    assert 2 = filtered_array[0];
    assert 8 = filtered_array[1];

    return ();
}

func keep_even{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(el: felt) -> (
    keep: felt
) {
    let (_, rest) = unsigned_div_rem(el, 2);
    return (1 - rest,);
}

@view
func test_filter_struct{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    let (local array: Foo*) = alloc();
    assert array[0] = Foo(1, 1);
    assert array[1] = Foo(1, 0);
    assert array[2] = Foo(2, 8);
    assert array[3] = Foo(7, 4);

    let (local filtered_array_len: felt, filtered_array: Foo*) = stream.filter_struct(
        keep_even_foo, 4, array, Foo.SIZE
    );

    assert 2 = filtered_array_len;
    assert Foo(1, 1) = filtered_array[0];
    assert Foo(2, 8) = filtered_array[1];

    return ();
}

struct Foo {
    x: felt,
    y: felt,
}

func keep_even_foo{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(el: Foo*) -> (
    keep: felt
) {
    tempvar sum = el.x + el.y;
    let (_, rest) = unsigned_div_rem(sum, 2);
    return (1 - rest,);
}
