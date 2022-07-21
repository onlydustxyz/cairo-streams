<div align="center">
  <h1 align="center">Cairo Streams</h1>
  <p align="center">
    <a href="https://discord.gg/onlydust">
        <img src="https://img.shields.io/badge/Discord-6666FF?style=for-the-badge&logo=discord&logoColor=white">
    </a>
    <a href="https://twitter.com/intent/follow?screen_name=onlydust_xyz">
        <img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white">
    </a>       
  </p>
  
  <h3 align="center">Array stream library written in pure Cairo</h3>
</div>

---

> ### ⚠️ WARNING! ⚠️
>
> This repo contains highly experimental code.
> Expect rapid iteration.
> **Use at your own risk.**


## Installation

### If you are using [Protostar](https://docs.swmansion.com/protostar/)

```bash
protostar install https://github.com/onlydustxyz/cairo-streams
```

### If you are using [StarkNet with a Python env](https://starknet.io/docs/quickstart.html) or [Nile](https://github.com/OpenZeppelin/nile)

```bash
pip install onlydust-cairo-streams
```

## Usage

To import the library in a cairo file, add this line:

```cairo
from onlydust.stream.default_implementation import stream
```

## Default implementations

### foreach

The foreach() method executes a provided function once for each array element.

Signature:
```cairo
func foreach(function : codeoffset, array_len : felt, array : felt*)
```

The provided function must have this signature exactly (including implicit params):
```cairo
func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(index : felt, element : felt*)
```

<details>
  <summary>Example</summary>

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

func do_something{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(index : felt, el : felt*):
    ...
    return ()
end
```

Look [here](./src/onlydust/stream/tests/test_foreach.cairo) for a full working example.
</details>

### foreach_struct

The foreach_struct() method executes a provided function once for each array element. Unlike foreach(), the array can be an array of structs.

Signature:
```cairo
func foreach_struct(function : codeoffset, array_len : felt, array : felt*, element_size : felt)
```

Assuming the struct is named `Foo`, the provided function must have this signature exactly (including implicit params):
```cairo
func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(index : felt, el : Foo*)
```

<details>
  <summary>Example</summary>

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
</details>

### filter

The filter() method executes a "filtering" callback function on each element of the array and keep only the elements that match.

Signature:
```cairo
func filter(function : codeoffset, array_len : felt, array : felt*) -> (filtered_array_len : felt, filtered_array : felt*)
```

The callback function must return `0` or `1` and must have this signature exactly (including implicit params):
```cairo
func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt) -> (keep : felt)
```

<details>
  <summary>Example</summary>

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

    assert 2 = filtered_array_len
    assert 2 = filtered_array[0]
    assert 8 = filtered_array[1]

    return ()
end

func keep_even{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : felt) -> (
    keep : felt
):
    let (_, rest) = unsigned_div_rem(el, 2)
    return (1 - rest)
end
```

Look [here](./src/onlydust/stream/tests/test_filter.cairo) for a full working example.
</details>


### filter_struct

The filter_struct() method executes a "filtering" callback function on each element of the array and keep only the elements that match.
Unlike filter(), the array can be an array of structs.

Signature:
```cairo
func filter_struct(function : codeoffset, array_len : felt, array : felt*, element_size : felt) -> (filtered_array_len : felt, filtered_array : felt*)
```

Assuming the struct is named `Foo`, the callback function must return `0` or `1` and must have this signature exactly (including implicit params):
```cairo
func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(el : Foo*) -> (keep : felt)
```

<details>
  <summary>Example</summary>

```cairo
struct Foo:
    member x : felt
    member y : felt
end

func test_filter_struct{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    let (local array : Foo*) = alloc()
    assert array[0] = Foo(1, 1)
    assert array[1] = Foo(1, 0)
    assert array[2] = Foo(2, 8)
    assert array[3] = Foo(7, 4)

    let (local filtered_array_len : felt, filtered_array : Foo*) = stream.filter_struct(
        keep_even_foo, 4, array, Foo.SIZE
    )

    assert 2 = filtered_array_len
    assert Foo(1, 1) = filtered_array[0]
    assert Foo(2, 8) = filtered_array[1]

    return ()
end

func keep_even_foo{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    el : Foo*
) -> (keep : felt):
    tempvar sum = el.x + el.y
    let (_, rest) = unsigned_div_rem(sum, 2)
    return (1 - rest)
end
```

Look [here](./src/onlydust/stream/tests/test_filter.cairo) for a full working example.
</details>


### map

The map() method executes a "mapping" callback function on each element of the array and store the returned value in-place of the processed element.

Signature:
```cairo
func map(function : codeoffset, array_len : felt, array : felt*) -> (mapped_array : felt*)
```

The callback function must have this signature exactly (including implicit params):
```cairo
func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(value : felt) -> (result : felt)
```

<details>
  <summary>Example</summary>

```cairo
func test_map{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    let (local array : felt*) = alloc()
    assert array[0] = 1
    assert array[1] = 2
    assert array[2] = 3
    assert array[3] = 4

    let (array) = stream.map(double, 4, array)

    assert 2 = array[0]
    assert 4 = array[1]
    assert 6 = array[2]
    assert 8 = array[3]

    return ()
end

func double{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(value : felt) -> (
    result : felt
):
    return (result=value * 2)
end
```

Look [here](./src/onlydust/stream/tests/test_map.cairo) for a full working example.
</details>


### map_struct

The map_struct() method executes a "mapping" callback function on each element of the array and store the returned value in-place of the processed element.
Unlike map(), the array can be an array of structs.

Signature:
```cairo
func map_struct(function : codeoffset, array_len : felt, array : felt*, element_size : felt) -> (mapped_array : felt*)
```

The callback function must have this signature exactly (including implicit params):
```cairo
func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(foo : Foo*) -> (result : Foo*)
```

<details>
  <summary>Example</summary>

```cairo
struct Foo:
    member x : felt
    member y : felt
end

func test_map_struct{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    let (local array : Foo*) = alloc()
    assert array[0] = Foo(1, 10)
    assert array[1] = Foo(2, 20)
    assert array[2] = Foo(3, 30)
    assert array[3] = Foo(4, 40)

    let (local array : Foo*) = stream.map_struct(double_foo, 4, array, Foo.SIZE)

    assert Foo(2, 20) = array[0]
    assert Foo(4, 40) = array[1]
    assert Foo(6, 60) = array[2]
    assert Foo(8, 80) = array[3]

    return ()
end

func double_foo{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(foo : Foo*) -> (
    result : Foo*
):
    return (new Foo(foo.x * 2, foo.y * 2))
end
```

Look [here](./src/onlydust/stream/tests/test_map.cairo) for a full working example.
</details>


### reduce

The reduce() method executes a "reducer" callback function on each element of the array.

Signature:
```cairo
func reduce(function : codeoffset, array_len : felt, array : felt*) -> (res : felt)
```

The callback function must have this signature exactly (including implicit params):
```cairo
func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(initial_value : felt, el : felt) -> (res : felt)
```

<details>
  <summary>Example</summary>

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

    # Reading a storage var will fail if builtins haven't been properly updated
    let (dummy) = dumb.read()

    return ()
end

func sum{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    initial_value : felt, el : felt
) -> (res : felt):
    let res = initial_value + el
    return (res)
end
```

Look [here](./src/onlydust/stream/tests/test_reduce.cairo) for a full working example.
</details>


### reduce_struct

The reduce_struct() method executes a "reducer" callback function on each element of the array. Unlike reduce(), the array can be an array of structs.

Signature:
```cairo
func reduce_struct(function : codeoffset, array_len : felt, array : felt*, element_size : felt) -> (res : felt*)
```

Assuming the struct is named `Foo`, the callback function must have this signature exactly (including implicit params):
```cairo
func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(initial_value : Foo*, element : Foo*) -> (res : Foo*)
```

<details>
  <summary>Example</summary>

```cairo
struct Foo:
    member x : felt
    member y : felt
end

func test_reduce_struct{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local array : Foo*) = alloc()
    assert array[0] = Foo(1, 10)
    assert array[1] = Foo(1, 10)
    assert array[2] = Foo(2, 20)
    assert array[3] = Foo(7, 70)

    let (res : Foo*) = stream.reduce_struct(
        function=sum_foo, array_len=4, array=array, element_size=Foo.SIZE
    )
    assert 11 = res.x
    assert 110 = res.y

    # Reading a storage var will fail if builtins haven't been properly updated
    let (dummy) = dumb.read()

    return ()
end

func sum_foo{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    initial_value : Foo*, element : Foo*
) -> (res : Foo*):
    return (new Foo(initial_value.x + element.x, initial_value.y + element.y))
end
```

Look [here](./src/onlydust/stream/tests/test_reduce.cairo) for a full working example.
</details>

### some

The some() method executes a function on each element and returns true if any element on the array returns true.

Signature:

```cairo
func some(function : codeoffset, array_len : felt, array : felt*) -> (res : felt)
```

The callback function must have this signature exactly (including implicit params):

```cairo
func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(index : felt, el : felt) -> (res : felt)
```

<details>
  <summary>Example</summary>

```cairo
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
```

Look [here](./src/onlydust/stream/tests/test_some.cairo) for a full working example.

</details>

### some_struct

The some_struct() method executes a function on each element and returns true if any element on the array returns true. Unlike some(), the array can be an array of structs.

Signature:

```cairo
func some_struct(function : codeoffset, array_len : felt, array : felt*, element_size : felt) -> (res : felt*)
```

Assuming the struct is named `Foo`, the callback function must have this signature exactly (including implicit params):

```cairo
func whatever{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(index : felt, element : Foo*) -> (res : felt)
```

And res should be `0` or `1`, `0` representing false, `1` true. Alternatively you can use the constants defined in the standard library.

<details>
  <summary>Example</summary>

```cairo
struct Foo:
    member x : felt
    member y : felt
end

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
```

Look [here](./src/onlydust/stream/tests/test_some.cairo) for a full working example.

</details>

## Custom implementations

You can implement your own functions, with custom implicit arguments, using the generic functions provided by the library:

```cairo
from onlydust.stream.generic import generic
```

To see implementation examples, the best is to look at the [default implementations](./src/onlydust/stream/default_implementation.cairo).
