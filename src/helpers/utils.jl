# Copyright 2025 Luis M. B. Varona, Nathaniel Johnston, and Sarah Plosker
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

module Utils

using Combinatorics: combinations
using ElasticArrays: ElasticMatrix
using LinearAlgebra: rank
using MatrixBandwidth: has_bandwidth_k_ordering
using MatrixBandwidth.Recognition: DelCorsoManzini
using SDiagonalizability

export norm_k_ortho_s_matrices, special_weak_hadamard

const DEFAULT_DECIDER = DelCorsoManzini()

function norm_k_ortho_s_matrices(n::Integer, k::Integer, S::Tuple{Vararg{Integer}})
    if n <= 0
        throw(DomainError(n, "Matrix order must be positive"))
    end

    if k <= 0
        throw(DomainError(k, "k-orthogonality parameter must be positive"))
    end

    if n == 1
        return [[1;;]]
    end

    S = SDiagonalizability._sort_tuple(S)
    eigvecs = SDiagonalizability.pot_nonkernel_s_eigvecs(n, S)

    if isempty(eigvecs)
        return Matrix{Int}[]
    end

    col_space = stack(eigvecs)
    num_eigvecs = size(col_space, 2)

    idxs_list_curr = ElasticMatrix(reshape(1:num_eigvecs, 1, num_eigvecs))
    depth = 1
    # Depends only on the maximum dimension and the eltype epsilon
    rtol = SDiagonalizability._rank_rtol(idxs_list_curr)

    while depth < n - 1
        idxs_list_next = ElasticMatrix{Int}(undef, depth += 1, 0)
        idxs_next_buf = Vector{Int}(undef, depth)

        for idxs_curr in eachcol(idxs_list_curr)
            idxs_next_buf[1:(depth - 1)] .= idxs_curr
            last = idxs_curr[end]

            for idx_next in (last + 1):num_eigvecs
                idxs_next_buf[end] = idx_next
                submatrix = view(col_space, :, idxs_next_buf)

                if rank(submatrix; rtol=rtol) == depth
                    gramian = submatrix' * submatrix
                    #= `MatrixBandwidth.jl` uses zero-based indexing for bandwidth, not
                    one-based, so we use `k - 1` instead of `k`. =#
                    band_res = has_bandwidth_k_ordering(gramian, k - 1, DEFAULT_DECIDER)

                    if band_res.has_ordering
                        append!(idxs_list_next, idxs_next_buf)
                    end
                end
            end
        end

        idxs_list_curr = idxs_list_next
    end

    mats = Vector{Matrix{Int}}(undef, size(idxs_list_curr, 2))
    mat_buf = Matrix{Int}(undef, n, n)
    mat_buf[:, 1] .= 1

    for (i, idxs) in enumerate(eachcol(idxs_list_curr))
        mat_buf[:, 2:end] .= view(col_space, :, idxs)
        gramian = mat_buf' * mat_buf
        #= `MatrixBandwidth.jl` uses zero-based indexing for bandwidth, not one-based, so we
        use `k - 1` instead of `k`. =#
        band_res = has_bandwidth_k_ordering(gramian, k - 1, DEFAULT_DECIDER)

        if !band_res.has_ordering
            error("Clearly, this should not happen: $band_res")
        end

        ordering = band_res.ordering
        mats[i] = mat_buf[ordering, ordering]
    end

    return mats
end

function special_weak_hadamard(n::Integer)
    if n <= 0
        throw(DomainError(n, "Matrix order must be positive"))
    end

    W = Matrix{Int}(undef, n, n)
    W[:, 1] .= 1

    for i in 2:n
        W[1:(i - 2), i] .= 0
        W[i - 1, i] = 1
        W[i, i] = -1
        W[(i + 1):n, i] .= 0
    end

    return W
end

end
