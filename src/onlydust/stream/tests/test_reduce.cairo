%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from onlydust.stream.default_implementation import stream
from onlydust.stream.tests.test_helper import sum_from_another_file, my_namespace

@storage_var
func dumb() -> (res: felt) {
}

@view
func test_reduce{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    let (local array: felt*) = alloc();
    assert array[0] = 1;
    assert array[1] = 1;
    assert array[2] = 1;
    assert array[3] = 7;

    let (res) = stream.reduce(sum, 4, array);
    assert res = 10;

    // Reading a storage var will fail if builtins haven't been properly updated
    let (dummy) = dumb.read();

    return ();
}

func sum{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    initial_value: felt, el: felt
) -> (res: felt) {
    let res = initial_value + el;
    return (res,);
}

@view
func test_reduce_with_sum_from_another_file{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;

    let (local array: felt*) = alloc();
    assert array[0] = 1;
    assert array[1] = 1;
    assert array[2] = 1;
    assert array[3] = 7;

    let (res) = stream.reduce(sum_from_another_file, 4, array);
    assert res = 10;

    return ();
}

@view
func test_reduce_with_sum_from_another_namespace{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;

    let (local array: felt*) = alloc();
    assert array[0] = 1;
    assert array[1] = 1;
    assert array[2] = 1;
    assert array[3] = 7;

    let (res) = stream.reduce(my_namespace.sum_from_another_namespace, 4, array);
    assert 10 = res;

    return ();
}

struct Foo {
    x: felt,
    y: felt,
}

@view
func test_reduce_struct{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (local array: Foo*) = alloc();
    assert array[0] = Foo(1, 10);
    assert array[1] = Foo(1, 10);
    assert array[2] = Foo(2, 20);
    assert array[3] = Foo(7, 70);

    let (res: Foo*) = stream.reduce_struct(
        function=sum_foo, array_len=4, array=array, element_size=Foo.SIZE
    );
    assert 11 = res.x;
    assert 110 = res.y;

    // Reading a storage var will fail if builtins haven't been properly updated
    let (dummy) = dumb.read();

    return ();
}

func sum_foo{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    initial_value: Foo*, element: Foo*
) -> (res: Foo*) {
    return (new Foo(initial_value.x + element.x, initial_value.y + element.y),);
}
