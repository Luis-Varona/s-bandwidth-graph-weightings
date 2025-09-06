# Copyright 2025 Luis M. B. Varona, Nathaniel Johnston, and Sarah Plosker
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

using MAT: matwrite
using Printf

include("helpers/utils.jl")
using .Utils

function main()
    dest, min_order, max_order, instructions, key_fmt = parse_cli_args()

    order_n_matrices(n::Int) =
        if instructions == ("special_wh",)
            [Matrix{Float64}(special_weak_hadamard(n))]
        else
            (k, S) = instructions
            Matrix{Float64}.(norm_k_ortho_s_matrices(n, k, S))
        end

    data = Dict(
        Iterators.map(
            n -> Printf.format(key_fmt, n) => order_n_matrices(n), min_order:max_order
        ),
    )
    return matwrite(dest, data; compress=true)
end

function parse_cli_args()
    num_args = length(ARGS)

    if num_args != 5
        throw(
            ArgumentError(
                "Expected five args, got $num_args: $(join(map(arg -> "'$arg'", ARGS), ", "))",
            ),
        )
    end

    dest = ARGS[1]
    min_order = parse(Int, ARGS[2])
    max_order = parse(Int, ARGS[3])
    instructions_str = split(ARGS[4], ";")
    key_fmt = Printf.Format(ARGS[5])

    if length(instructions_str) == 1 && instructions_str[1] == "special_wh"
        instructions = ("special_wh",)
    elseif length(instructions_str) == 2
        k = parse(Int, instructions_str[1])
        S = tuple(
            sort!(map(token -> parse(Int, token), split(instructions_str[2], ",")))...
        )
        instructions = (k, S)
    else
        throw(
            ArgumentError(
                "Fourth argument must be either 'special_wh' or follow the format 'k;S', where k is a positive integer and S is a comma-separated list of integers",
            ),
        )
    end

    if ispath(dest)
        throw(ArgumentError("Destination already exists: '$dest'"))
    end

    if !endswith(dest, ".mat")
        throw(ArgumentError("Destination file must have a '.mat' extension: '$dest'"))
    end

    if min_order <= 0
        throw(ArgumentError("Minimum graph order must be positive, got $min_order"))
    end

    if max_order < min_order
        throw(
            ArgumentError("Maximum graph order must be at least $min_order, got $max_order")
        )
    end

    if length(instructions) == 2
        if k <= 0
            throw(ArgumentError("Bandwidth must be positive, got $k"))
        end

        if S != (-1, 0, 1) && S != (-1, 1)
            throw(
                ArgumentError(
                    "Entry set must be either '-1,0,1', '-1,1', or a permutation thereof, got $(instructions_str[2])",
                ),
            )
        end
    end

    mkpath(dirname(dest))

    return dest, min_order, max_order, instructions, key_fmt
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
