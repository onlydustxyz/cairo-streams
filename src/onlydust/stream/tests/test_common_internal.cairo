%lang starknet

from onlydust.stream.internal.common import new_zero_value

struct Foo:
    member x : felt
    member y : felt
end

@view
func test_new_zero_value_struct():
    let (value : felt*) = new_zero_value(Foo.SIZE)
    assert 0 = value[0]
    assert 0 = value[1]

    let foo : Foo* = cast(value, Foo*)
    assert 0 = foo.x
    assert 0 = foo.y

    return ()
end

@view
func test_new_zero_value_felt():
    let (value : felt*) = new_zero_value(1)
    assert 0 = value[0]

    let val : felt = [value]
    assert 0 = val

    return ()
end
