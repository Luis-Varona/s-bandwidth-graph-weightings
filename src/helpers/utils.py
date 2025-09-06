# Copyright 2025 Luis M. B. Varona
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

from subprocess import run

import networkx as nx


def nauty_geng_to_nx_graphs(*geng_flags: str) -> list[nx.Graph]:
    res = run(["geng", *geng_flags], capture_output=True)
    res.check_returncode()
    graph6_strings = res.stdout.decode("ascii").strip().split("\n")
    return (nx.from_graph6_bytes(g6.encode("ascii")) for g6 in graph6_strings)
