%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.registers import get_ap
from starkware.cairo.common.invoke import invoke as invoke_internal
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.alloc import alloc

namespace foreach_internal:
    namespace custom_implicits:
        func foreach_loop(
            func_pc : felt,
            array_len : felt,
            array : felt*,
            index : felt,
            element_size : felt,
            implicit_params_len : felt,
            implicit_params : felt*,
        ) -> (implicit_params : felt*):
            alloc_locals
            if index == array_len:
                return (implicit_params)
            end

            # Put function arguments in appropriate memory cells
            let (local args : felt*) = alloc()
            memcpy(args, implicit_params, implicit_params_len)
            assert args[implicit_params_len] = index
            assert args[implicit_params_len + 1] = cast(array, felt)

            # Call the function
            invoke_internal(func_pc, implicit_params_len + 2, args)

            # Update implicit parameters
            let (ap_val) = get_ap()
            let implicit_params : felt* = cast(ap_val - implicit_params_len, felt*)

            # Process next element
            return foreach_loop(
                func_pc,
                array_len,
                array + element_size,
                index + 1,
                element_size,
                implicit_params_len,
                implicit_params,
            )
        end
    end

    namespace no_implicits:
        func foreach_loop(
            func_pc : felt, array_len : felt, array : felt*, index : felt, element_size : felt
        ):
            if index == array_len:
                return ()
            end

            # Put function arguments in appropriate memory cells
            [ap] = index; ap++
            [ap] = array; ap++

            # Call the function
            call abs func_pc

            # Process next element
            foreach_loop(func_pc, array_len, array + element_size, index + 1, element_size)
            return ()
        end
    end

    namespace common_implicits:
        func foreach_loop{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
            func_pc : felt, array_len : felt, array : felt*, index : felt, element_size : felt
        ):
            if index == array_len:
                return ()
            end

            # Put function arguments in appropriate memory cells
            [ap] = syscall_ptr; ap++
            [ap] = pedersen_ptr; ap++
            [ap] = range_check_ptr; ap++
            [ap] = index; ap++
            [ap] = array; ap++

            # Call the function
            call abs func_pc

            # Update implicit parameters
            let syscall_ptr : felt* = cast([ap - 3], felt*)
            let pedersen_ptr : HashBuiltin* = cast([ap - 2], HashBuiltin*)
            let range_check_ptr = [ap - 1]

            # Process next element
            foreach_loop(func_pc, array_len, array + element_size, index + 1, element_size)
            return ()
        end
    end

    namespace full_implicits:
        func foreach_loop{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr,
            bitwise_ptr : BitwiseBuiltin*,
        }(func_pc : felt, array_len : felt, array : felt*, index : felt, element_size : felt):
            if index == array_len:
                return ()
            end

            # Put function arguments in appropriate memory cells
            [ap] = syscall_ptr; ap++
            [ap] = pedersen_ptr; ap++
            [ap] = range_check_ptr; ap++
            [ap] = bitwise_ptr; ap++
            [ap] = index; ap++
            [ap] = array; ap++

            # Call the function
            call abs func_pc

            # Update implicit parameters
            let syscall_ptr : felt* = cast([ap - 4], felt*)
            let pedersen_ptr : HashBuiltin* = cast([ap - 3], HashBuiltin*)
            let range_check_ptr = [ap - 2]
            let bitwise_ptr : BitwiseBuiltin* = cast([ap - 1], BitwiseBuiltin*)

            # Process next element
            foreach_loop(func_pc, array_len, array + element_size, index + 1, element_size)
            return ()
        end
    end
end
