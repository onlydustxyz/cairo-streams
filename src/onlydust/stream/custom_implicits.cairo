%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin

from starkware.cairo.common.registers import get_label_location
from onlydust.stream.internal.foreach import foreach_internal
from onlydust.stream.internal.reduce import reduce_internal
from onlydust.stream.internal.filter import filter_internal

namespace stream:
    struct Implicit:
        member count : felt
        member arguments : felt*
    end

    func no_implicit() -> (implicit : Implicit):
        return (implicit=Implicit(0, new ()))
    end

    func with_implicit(implicit_args : felt*, implicit_args_len : felt) -> (implicit : Implicit):
        return (implicit=Implicit(implicit_args_len, implicit_args))
    end

    func foreach{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, array_len : felt, array : felt*
    ):
        foreach_struct(function, array_len, array, 1)
        return ()
    end

    func foreach_struct{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, array_len : felt, array : felt*, element_size : felt
    ):
        let (implicit) = stream.with_implicit(new (syscall_ptr, pedersen_ptr, range_check_ptr), 3)

        with implicit:
            stream.custom.foreach_struct(function, array_len, array, element_size)
            stream.syscall_ptr.pedersen_ptr.range_check_ptr.update()
        end
        return ()
    end

    namespace custom:
        # The foreach() method executes a provided function once for each array element.
        # The provided function must have this signature:
        #   func whatever(el : felt*)
        func foreach{implicit : Implicit}(function : codeoffset, array_len : felt, array : felt*):
            foreach_struct(function, array_len, array, 1)
            return ()
        end

        # The foreach() method executes a provided function once for each array element.
        # The provided function must have this signature:
        #   func whatever(el : felt*)
        func foreach_struct{implicit : Implicit}(
            function : codeoffset, array_len : felt, array : felt*, element_size : felt
        ):
            let (func_pc) = get_label_location(function)

            let (updated_implicit_params : felt*) = foreach_internal.foreach_loop(
                func_pc, array_len, array, 0, element_size, implicit.count, implicit.arguments
            )
            let implicit = Implicit(count=implicit.count, arguments=updated_implicit_params)
            return ()
        end
    end

    namespace syscall_ptr:
        func update{syscall_ptr : felt*, implicit : Implicit}():
            let syscall_ptr = cast(implicit.arguments[0], felt*)
            return ()
        end

        namespace pedersen_ptr:
            func update{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, implicit : Implicit}():
                let syscall_ptr = cast(implicit.arguments[0], felt*)
                let pedersen_ptr = cast(implicit.arguments[1], HashBuiltin*)
                return ()
            end

            namespace range_check_ptr:
                func update{
                    syscall_ptr : felt*,
                    pedersen_ptr : HashBuiltin*,
                    range_check_ptr,
                    implicit : Implicit,
                }():
                    let syscall_ptr = cast(implicit.arguments[0], felt*)
                    let pedersen_ptr = cast(implicit.arguments[1], HashBuiltin*)
                    let range_check_ptr = implicit.arguments[2]
                    return ()
                end

                namespace bitwise_ptr:
                    func update{
                        syscall_ptr : felt*,
                        pedersen_ptr : HashBuiltin*,
                        range_check_ptr,
                        bitwise_ptr : BitwiseBuiltin*,
                        implicit : Implicit,
                    }():
                        let syscall_ptr = cast(implicit.arguments[0], felt*)
                        let pedersen_ptr = cast(implicit.arguments[1], HashBuiltin*)
                        let range_check_ptr = implicit.arguments[2]
                        let bitwise_ptr : BitwiseBuiltin* = cast(implicit.arguments[3], BitwiseBuiltin*)
                        return ()
                    end
                end
            end
        end
    end
end
