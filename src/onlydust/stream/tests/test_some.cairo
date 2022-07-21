%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE

from onlydust.stream.default_implementation import stream
from onlydust.stream.tests.test_helper import is_one_from_another_file, my_namespace

@storage_var
func dumb() -> (res : felt):
end

@view
func test_some{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 0
    assert array[1] = 2
    assert array[2] = 1
    assert array[3] = 7

    let (res) = stream.some(is_one, 4, array)
    assert res = TRUE

    # Reading a storage var will fail if builtins haven't been properly updated
    let (dummy) = dumb.read()

    return ()
end

func is_one{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    index : felt, el : felt
) -> (res : felt):
    if el == 1:
        return (TRUE)
    end
    return (FALSE)
end

@view
func test_some_element_not_found{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 0
    assert array[1] = 2
    assert array[2] = 2
    assert array[3] = 7

    let (res) = stream.some(is_one, 4, array)
    assert res = FALSE

    # Reading a storage var will fail if builtins haven't been properly updated
    let (dummy) = dumb.read()

    return ()
end

@view
func test_some_with_one_from_another_file{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 0
    assert array[1] = 2
    assert array[2] = 1
    assert array[3] = 7

    let (res) = stream.some(is_one_from_another_file, 4, array)
    assert res = TRUE

    return ()
end

@view
func test_some_with_is_one_from_another_namespace{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 0
    assert array[1] = 2
    assert array[2] = 1
    assert array[3] = 7

    let (res) = stream.some(my_namespace.is_one_from_another_namespace, 4, array)
    assert res = TRUE

    return ()
end

struct Foo:
    member x : felt
    member y : felt
end

@view
func test_some_struct{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local array : Foo*) = alloc()
    assert array[0] = Foo(0, 10)
    assert array[1] = Foo(1, 10)
    assert array[2] = Foo(2, 20)
    assert array[3] = Foo(7, 70)

    let (res : felt) = stream.some_struct(
        function=is_one_foo, array_len=4, array=array, element_size=Foo.SIZE
    )
    assert res = TRUE

    # Reading a storage var will fail if builtins haven't been properly updated
    let (dummy) = dumb.read()

    return ()
end

@view
func test_some_struct_element_not_found{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    let (local array : Foo*) = alloc()
    assert array[0] = Foo(0, 10)
    assert array[1] = Foo(4, 10)
    assert array[2] = Foo(2, 20)
    assert array[3] = Foo(7, 70)

    let (res : felt) = stream.some_struct(
        function=is_one_foo, array_len=4, array=array, element_size=Foo.SIZE
    )
    assert res = FALSE

    # Reading a storage var will fail if builtins haven't been properly updated
    let (dummy) = dumb.read()

    return ()
end

func is_one_foo{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    index : Foo*, element : Foo*
) -> (res : felt):
    if element.x == 1:
        return (TRUE)
    end
    if element.y == 1:
        return (TRUE)
    end
    return (FALSE)
end
