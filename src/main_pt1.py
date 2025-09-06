# Copyright 2025 Luis M. B. Varona, Nathaniel Johnston, and Sarah Plosker
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

import os
from re import fullmatch
from sys import argv

import networkx as nx
import numpy as np
import polars as pl
from scipy.io import savemat

from helpers.sql_mapping import read_table_as_polars_df
from helpers.utils import nauty_geng_to_nx_graphs


def main() -> None:
    (
        source,
        dest,
        min_order,
        max_order,
        k,
        table_name,
        order_col,
        g6_col,
        S_band_col,
        key_fmt,
    ) = parse_cli_args()

    graphs_kept = {key_fmt % (n,): [] for n in range(min_order, max_order + 1)}

    df = (
        read_table_as_polars_df(source, table_name)
        .filter(
            (pl.col(order_col).is_between(min_order, max_order))
            & (pl.col(S_band_col) <= k)
        )
        .group_by(order_col)
        .agg(pl.col(g6_col))
    )
    graphs_excl = dict(
        zip(
            df.get_column(order_col).to_list(),
            [
                [nx.from_graph6_bytes(g6.encode("ascii")) for g6 in g6_list]
                for g6_list in df.get_column(g6_col)
            ],
        )
    )

    for n in range(min_order, max_order + 1):
        key = key_fmt % (n,)

        for g in nauty_geng_to_nx_graphs(str(n), "-c", "-l"):
            if not any(nx.is_isomorphic(g, h) for h in graphs_excl.get(n, [])):
                graphs_kept[key].append(nx.laplacian_matrix(g).toarray().astype(float))

    for key in graphs_kept:
        arr_tmp = np.empty(len(graphs_kept[key]), dtype=object)

        for i, L in enumerate(graphs_kept[key]):
            arr_tmp[i] = L

        graphs_kept[key] = arr_tmp

    savemat(dest, graphs_kept, do_compression=True, oned_as="column")


def parse_cli_args() -> tuple[str, str, int, int, int, str, str, str, str, str]:
    num_args = len(argv) - 1

    if num_args != 10:
        args_fmtd = ", ".join([f"'{arg}'" for arg in argv[1:]])
        raise ValueError(f"Expected ten arguments, got {num_args}:\n{args_fmtd}")

    source = argv[1]
    dest = argv[2]
    min_order = int(argv[3])
    max_order = int(argv[4])
    k = int(argv[5])
    table_name = argv[6]
    order_col = argv[7]
    g6_col = argv[8]
    S_band_col = argv[9]
    key_fmt = argv[10]

    if not os.path.isfile(source):
        raise FileNotFoundError(f"Source file does not exist: '{source}'")

    if os.path.exists(dest):
        raise FileExistsError(f"Destination already exists: '{dest}'")

    if not dest.endswith(".mat"):
        raise ValueError(f"Destination file must have a '.mat' extension: '{dest}'")

    if min_order <= 0:
        raise ValueError(f"Minimum order must be positive, got {min_order}")

    if max_order < min_order:
        raise ValueError(
            f"Maximum graph order must be at least {min_order}, got {max_order}"
        )

    if k <= 0:
        raise ValueError(f"Bandwidth cutoff must be positive, got {k}")

    if not fullmatch(r"[a-zA-Z_][a-zA-Z0-9_]*", table_name):
        raise ValueError(f"Invalid table name: '{table_name}'")

    return (
        source,
        dest,
        min_order,
        max_order,
        k,
        table_name,
        order_col,
        g6_col,
        S_band_col,
        key_fmt,
    )


if __name__ == "__main__":
    main()
