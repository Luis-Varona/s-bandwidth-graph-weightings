% Copyright 2025 Luis M. B. Varona
%
% Licensed under the MIT license <LICENSE or
% http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
% distributed except according to those terms.

function main_pt3(source_L, source_P, dest, min_order, max_order, key_fmt)
    % To avoid RCOND warnings in CVX, which would only result in false positives anyway, not
    % false negatives.
    warning('off', 'all');

    diary(dest);

    addDependencies();

    tmp_data_L = load(source_L);
    tmp_data_P = load(source_P);

    data_L = containers.Map('KeyType', 'uint32', 'ValueType', 'any');
    data_P = containers.Map('KeyType', 'uint32', 'ValueType', 'any');

    for n = min_order:max_order
        data_L(n) = tmp_data_L.(sprintf(key_fmt, n));
        data_P(n) = tmp_data_P.(sprintf(key_fmt, n));
    end

    for n = min_order:max_order
        data_L_n = data_L(n);
        data_P_n = data_P(n);
        num_P_n = numel(data_P_n);

        iter_data = [n, length(data_L_n), num_P_n];
        iter_data

        for ii = 1:numel(data_L_n)
            L = data_L_n{ii};

            for jj = 1:num_P_n
                P = data_P_n{jj};
                res = isPDiagWithWeights(L, P);

                if res.has_weights
                    res.L
                    res.weights
                    break;
                end
            end
        end

        fprintf("Completed order %d\n", n);
    end

    diary off;
end

function addDependencies()
    addpath(genpath(fullfile(fileparts(mfilename("fullpath")), "helpers")));
end
