% Copyright 2025 Luis M. B. Varona
%
% Licensed under the MIT license <LICENSE or
% http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
% distributed except according to those terms.

function res = isPDiagWithWeights(L, P)
    res.L = L;
    res.P = P;

    n = size(L, 1);
    A = laplacianToAdjacency(L);

    cvx_begin quiet
        % variable weights(nnz(A) / 2)
        variable weights(nnz(A) / 2) complex
        A_weighted = zeros(n) .* weights(1);
        A_weighted(A == 1) = repmat(weights, [2, 1]);
        L_weighted = adjacencyToLaplacian(A_weighted);
        D = P \ L_weighted * P;

        minimize max(real(weights))
        subject to
            % weights >= 1;
            real(weights) >= 1;
            D == diag(diag(D));
    cvx_end

    if cvx_optval < Inf
        A(A == 1) = repmat(weights, [2, 1]);
        L_weighted = adjacencyToLaplacian(A);

        res.weights = weights;
        res.L_weighted = L_weighted;
        res.has_weights = true;
    else
        res.weights = [];
        res.L_weighted = [];
        res.has_weights = false;
    end
end

function L = adjacencyToLaplacian(A)
    L = -A;
    L(1:size(A,1)+1:end) = sum(A);
end

function A = laplacianToAdjacency(L)
    A = -L;
    A(1:size(L,1)+1:end) = 0;
end
