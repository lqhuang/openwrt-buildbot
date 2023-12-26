#!/bin/env python
from __future__ import annotations

import re
from argparse import ArgumentParser
from pathlib import Path
from typing import Optional


def is_glob_pattern(s: str) -> bool:
    # https://docs.python.org/3/library/fnmatch.html
    hashed = set(s)
    patterns = {"*", "?", "[", "]", "!"}
    if hashed & patterns:
        return True
    else:
        return False


def rename_package(line: str) -> Optional[str]:
    line = str(line)
    if not line or line.startswith("#"):
        return None
    else:
        pattern = re.compile(r"#(.*)")
        striped = pattern.sub("", line).strip()
        if striped.startswith("-"):
            return f"CONFIG_PACKAGE_{striped.strip('-').strip()}=n"
        else:
            return f"CONFIG_PACKAGE_{striped}=y"


if __name__ == "__main__":
    arg_parser = ArgumentParser(
        description="Load package names from files and append to config"
    )
    arg_parser.add_argument("files", nargs="+", help="Input files or file paatern.")
    arg_parser.add_argument(
        "-o", "--output", action="store", help="output file", default="packages.config"
    )
    arg_parser.add_argument(
        "-w",
        "--write",
        action="store_true",
        help="Write to file (output file will be overwritten if existed)",
    )
    arg_parser.add_argument(
        "-a",
        "--append",
        action="store_true",
        help="Append content to output file",
    )
    args = arg_parser.parse_args()

    if args.write and args.append:
        raise ValueError(
            "Could specify only one option between '--write' and '--append'."
        )

    if is_glob_pattern(args.files):
        files = tuple(Path("").glob(args.files))
        if not files:
            raise ValueError("Input files don't not exist")
        lines = [line for f in files for line in f.read_text().splitlines()]
    else:
        lines = []
        for each in args.files:
            input_file = Path(each).resolve()
            if not input_file.exists():
                raise ValueError("Input file does not exist")
            if not input_file.is_file():
                raise ValueError("Input file is not a file")
            lines.extend(input_file.read_text().splitlines())

    packages = filter(None, map(rename_package, lines))
    output_lines = sorted(packages)

    if args.write:
        output = Path(args.output).resolve()
        if output.is_file():
            raise Warning("Output file already exists, will be overwritten ...")
        mode = "w"
        output.write_text("\n".join(output_lines) + "\n")
    elif args.append:
        mode = "a"
        output = Path(args.output).resolve()
        with output.open(mode) as f:
            f.writelines(output_lines)
    else:  # write to stdout
        print("\n".join(output_lines))
