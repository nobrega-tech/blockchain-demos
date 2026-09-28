"""CLI for the Python blockchain demo.

  python __main__.py [dificuldade]
  python __main__.py bench --difficulty 16 --blocks 5 --txs-per-block 0
  python __main__.py test
"""

from __future__ import annotations

import sys

from blockchain import BenchArgs, bench_print_json, bench_run, demo_run
from test_blockchain import run_tests


def _parse_u32(s: str) -> int:
    v = int(s, 10)
    if v < 0:
        raise ValueError("negativo")
    return v


def main(argv: list[str]) -> int:
    if len(argv) >= 1 and argv[0] == "bench":
        args = BenchArgs()
        i = 1
        while i < len(argv):
            if argv[i] == "--difficulty" and i + 1 < len(argv):
                args.difficulty = _parse_u32(argv[i + 1])
                i += 2
            elif argv[i] == "--blocks" and i + 1 < len(argv):
                args.blocks = _parse_u32(argv[i + 1])
                i += 2
            elif argv[i] == "--txs-per-block" and i + 1 < len(argv):
                args.txs_per_block = _parse_u32(argv[i + 1])
                i += 2
            else:
                print(f"flag desconhecida: {argv[i]}", file=sys.stderr)
                return 2
        result = bench_run(args)
        bench_print_json(args, result)
        return 0

    if len(argv) >= 1 and argv[0] == "test":
        return run_tests()

    difficulty = 12
    if len(argv) >= 1:
        try:
            difficulty = _parse_u32(argv[0])
        except ValueError:
            print(
                "uso: python __main__.py [dificuldade] | bench [...] | test",
                file=sys.stderr,
            )
            return 2
    demo_run(difficulty)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))