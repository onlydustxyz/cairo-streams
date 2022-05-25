%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy

# Returns the argument as a felt or a felt* depending on its size
#    - if argument_size == 1, the argument is a felt, returns it
#    - if argument_size > 1, the argument is a struct, returns the pointer to it
func prepare_argument(argument_pointer : felt*, argument_size : felt) -> (argument : felt):
    if argument_size == 1:
        return (argument=[argument_pointer])
    end

    return (argument=cast(argument_pointer, felt))
end

# Returns the result at ap_val-1 as a felt*
#    - if size == 1, the result is a felt, returns the pointer to its value
#    - if size > 1, the result is a struct, returns the value itself (it's already a pointer)
func retrieve_result(ap_val : felt, size : felt) -> (result : felt*):
    if size == 1:
        return (result=cast(ap_val - 1, felt*))
    end

    return (result=cast([ap_val - 1], felt*))
end

# Append an element to an array
#    - if element_size == 1, element is a felt, just setting it
#    - if element_size > 1, element is a struct, using memcpy to copy the entire struct into the array
func append_element(array : felt*, element : felt, element_size : felt):
    if element_size == 1:
        [array] = element
    else:
        memcpy(array, cast(element, felt*), element_size)
    end

    return ()
end

# Returns the zero-value of any felt/struct, as a felt*
#    - if size == 1, the value is a felt, returns an array containing one felt equal to zero
#    - if size > 1, the value is a struct, returns an array of felts equal to zero, of length equal to size
func new_zero_value(size : felt) -> (zero_value : felt*):
    if size == 1:
        return (new (0))  # quick-win for felts
    end

    let (zero_value : felt*) = alloc()
    return new_zero_value_loop(zero_value, size, 0)
end

func new_zero_value_loop(zero_value : felt*, size : felt, index : felt) -> (zero_value : felt*):
    if index == size:
        return (zero_value)
    end

    assert zero_value[index] = 0
    return new_zero_value_loop(zero_value, size, index + 1)
end
