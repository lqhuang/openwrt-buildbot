#!/bin/env python

import sys
from argparse import ArgumentParser
from pathlib import Path

if __name__ == "__main__":
    arg_parser = ArgumentParser(description="Sort names in a file")
    arg_parser.add_argument("file", help="file to sort")
    arg_parser.add_argument(
        "-i",
        "--inplace",
        action="store_true",
        default=True,
        help="inplace update to the input file",
    )
    arg_parser.add_argument("-o", "--output", action="store", help="output file")
    args = arg_parser.parse_args()

    if args.output is not None and args.inplace:
        raise ValueError("Already have an output file, cannot set 'inplace' option")

    input_file = Path(args.file).resolve()

    if not input_file.exists():
        raise ValueError("Input file does not exist")
    if not input_file.is_file():
        raise ValueError("Input file is not a file")

    print(f"Sorting names in file '{input_file}' ...")
    input_lines = set(filter(None, input_file.read_text().splitlines()))
    output_lines = sorted(list(input_lines))

    if args.output is not None:
        output = Path(args.output).resolve()
        if output.is_file():
            raise Warning("Output file already exists, will be overwritten ...")
    elif args.inplace:
        output = input_file
    else:

        class Output:
            def write_text(self, text):
                sys.stdout.write(text)
                sys.stdout.flush()

        output = Output()

    output.write_text("\n".join(output_lines) + "\n")
