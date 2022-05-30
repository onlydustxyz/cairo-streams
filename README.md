<div align="center">
  <h1 align="center">Cairo Streams</h1>
  <p align="center">
    <a href="http://makeapullrequest.com">
      <img alt="pull requests welcome badge" src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat">
    </a>
    <a href="https://twitter.com/intent/follow?screen_name=onlydust_xyz">
        <img src="https://img.shields.io/twitter/follow/onlydust_xyz?style=social&logo=twitter"
            alt="follow on Twitter"></a>
    <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-green"
            alt="License"></a>
    <a href=""><img src="https://img.shields.io/badge/semver-0.0.1-blue"
            alt="Version"></a>            
  </p>
  
  <h3 align="center">Array stream library written in pure Cairo</h3>
</div>

> ### ⚠️ WARNING! ⚠️
>
> This repo contains highly experimental code.
> Expect rapid iteration.
> **Use at your own risk.**

As this library is written in pure Cairo, without hint, you can use it in your StarkNet contracts without any issue.

## Install the library

### If you are using [Protostar](https://docs.swmansion.com/protostar/)

```bash
protostar install https://github.com/onlydustxyz/cairo-streams
```

### If you are using [StarkNet with a Python env](https://starknet.io/docs/quickstart.html) or [Nile](https://github.com/OpenZeppelin/nile)

Coming soon. A pip package will be created for your convenience, so you will be able to install it with `pip install`.


## Usage

To import the library in a cairo file, add this line:

```cairo
from onlydust.stream.library import stream
```

### foreach

The foreach() method executes a provided function once for each array element.

Signature: `func foreach(func_label_value : codeoffset, array_len : felt, array : felt*)`.

The provided function must have this signature exactly (including implicit params): `func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt*)`.

Example:

```cairo
func test_foreach{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 1
    assert array[1] = 1
    assert array[2] = 1
    assert array[3] = 7

    stream.foreach(do_something, 4, array)

    return ()
end

func do_something{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt*):
    ...
    return ()
end
```

Look [here](./src/onlydust/stream/tests/test_foreach.cairo) for a full working example.

### foreach_struct

The foreach_struct() method executes a provided function once for each array element. Unlike foreach(), the array can be an array of structs.

Signature: `func foreach_struct(func_label_value : codeoffset, array_len : felt, array : felt*, element_size : felt)`.

The provided function must have this signature exactly (including implicit params): `func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : Foo*)` (assuming your struct is named Foo).

Example:

```cairo
struct Foo:
    member x : felt
    member y : felt
end

func test_foreach_struct{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    let (local array : Foo*) = alloc()
    assert array[0] = Foo(1, 10)
    assert array[1] = Foo(1, 10)
    assert array[2] = Foo(2, 20)
    assert array[3] = Foo(7, 70)

    stream.foreach_struct(do_something, 4, array, Foo.SIZE)

    return ()
end

func do_something{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : Foo*):
    ...
    return ()
end
```

Look [here](./src/onlydust/stream/tests/test_foreach.cairo) for a full working example.

### filter

The filter() method executes a "filtering" callback function on each element of the array and keep only the elements that match.

Signature: `func filter(func_label_value : codeoffset, array_len : felt, array : felt*) -> (filtered_array_len : felt, filtered_array : felt*)`.

The callback function must have this signature exactly (including implicit params): `func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(initial_value : felt, el : felt) -> (res : felt)`.

Example:

```cairo
func test_filter{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 1
    assert array[1] = 2
    assert array[2] = 8
    assert array[3] = 7

    let (local filtered_array_len : felt, filtered_array : felt*) = stream.filter(
        keep_even, 4, array
    )

    assert filtered_array_len = 2
    assert filtered_array[0] = 2
    assert filtered_array[1] = 8

    return ()
end

func keep_even{range_check_ptr}(el : felt) -> (keep : felt):
    let (_, rest) = unsigned_div_rem(el, 2)
    return (1 - rest)
end
```

Look [here](./src/onlydust/stream/tests/test_filter.cairo) for a full working example.

### reduce

The reduce() method executes a "reducer" callback function on each element of the array.

Signature: `func reduce(func_label_value : codeoffset, array_len : felt, array : felt*) -> (res : felt)`.

The callback function must have this signature exactly (including implicit params): `func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(initial_value : felt, el : felt) -> (res : felt)`.

Example:

```cairo
func test_reduce{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 1
    assert array[1] = 1
    assert array[2] = 1
    assert array[3] = 7

    let (res) = stream.reduce(sum, 4, array)
    assert res = 10

    return ()
end

func sum(initial_value : felt, el : felt) -> (res : felt):
    let res = initial_value + el
    return (res)
end
```

Look [here](./src/onlydust/stream/tests/test_reduce.cairo) for a full working example.
