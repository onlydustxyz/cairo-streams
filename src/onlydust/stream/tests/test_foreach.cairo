%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from onlydust.stream.lib import stream

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

    stream.foreach(inc_counter, 4, array)

    let (count) = counter.read()
    assert count = 10

    return ()
end

func inc_counter{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    index : felt, el : felt*
):
    let (count) = counter.read()
    counter.write(count + [el])
    return ()
end

@view
func test_foreach_with_custom_implicits{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 1
    assert array[1] = 1
    assert array[2] = 1
    assert array[3] = 7

    let plop = 40

    let (implicit) = stream.with_implicit(
        new inc_counter_with_custom_implicit.ImplicitArgs(syscall_ptr, pedersen_ptr, range_check_ptr, plop),
        inc_counter_with_custom_implicit.ImplicitArgs.SIZE,
    )

    with implicit:
        stream.custom.foreach(inc_counter_with_custom_implicit, 4, array)
        stream.syscall_ptr.pedersen_ptr.range_check_ptr.update()
    end

    let implicit_struct = cast(implicit.arguments, inc_counter_with_custom_implicit.ImplicitArgs*)
    assert 44 = implicit_struct.plop

    let (count) = counter.read()
    assert count = 10

    return ()
end

func inc_counter_with_custom_implicit{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, plop
}(index : felt, el : felt*):
    let plop = plop + 1
    let (count) = counter.read()
    counter.write(count + [el])
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

    stream.foreach_struct(function=inc_counter_foo, array_len=4, array=array, element_size=Foo.SIZE)

    let (count_x) = counter_x.read()
    assert count_x = 11

    let (count_y) = counter_y.read()
    assert count_y = 110

    return ()
end

func inc_counter_foo{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    index : felt, el : felt*
):
    let foo : Foo = [cast(el, Foo*)]

    let (count_x) = counter_x.read()
    counter_x.write(count_x + foo.x)

    let (count_y) = counter_y.read()
    counter_y.write(count_y + foo.y)
    return ()
end

@view
func test_foreach_no_implicits():
    alloc_locals

    let (local array : felt*) = alloc()

    let (implicit) = stream.no_implicit()
    with implicit:
        stream.custom.foreach(set42, 4, array)
    end

    assert 42 = array[0]
    assert 42 = array[1]
    assert 42 = array[2]
    assert 42 = array[3]

    return ()
end

func set42(index : felt, el : felt*):
    assert [el] = 42
    return ()
end
