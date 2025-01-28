import sys
from typing import List, NoReturn


def print_usage() -> NoReturn:
    """
    Display usage instructions and exit the program.

    # Example
    ```python
    import sys
    sys.argv = ["script.py"]
    try:
        print_usage()
    except SystemExit as e:
        assert e.code == 1
    ```
    """
    print("Usage:", sys.argv[0], "[bytes per line] [filename]")
    exit(1)


def parse_args(args: List[str]) -> tuple[int, str]:
    """
    Parse and validate command-line arguments.

    # Arguments
    - `args`: List of command-line arguments.

    # Returns
    A tuple containing:
    - `bytes_per_line` (int): Number of bytes to display per line.
    - `file_name` (str): The name of the file to process.

    # Panics
    Exits the program if:
    - `args` does not contain exactly two elements.
    - The first argument is not a positive integer.

    # Example
    ```python
    assert parse_args(["16", "example.bin"]) == (16, "example.bin")

    import sys
    sys.argv = ["script.py"]
    try:
        parse_args([])
    except SystemExit as e:
        assert e.code == 1
    ```
    """
    if len(args) != 2:
        print_usage()

    try:
        bytes_per_line: int = int(args[0])
        if bytes_per_line <= 0:
            raise ValueError("Bytes per line must be a positive integer.")
    except ValueError as e:
        print("Error:", e)
        print_usage()

    file_name = args[1]
    return bytes_per_line, file_name


def read_binary_file(file_name: str) -> List[int]:
    """
    Read a binary file and return its contents as a list of bytes.

    # Arguments
    - `file_name`: Name of the binary file to read.

    # Returns
    A list of integers representing the bytes in the file.

    # Panics
    Exits the program if:
    - The file is not found.
    - The file cannot be read.

    # Example
    ```python
    import os

    # Create a temporary binary file
    with open("test.bin", "wb") as f:
        f.write(b'\x01\x02\x03')

    assert read_binary_file("test.bin") == [1, 2, 3]
    os.remove("test.bin")
    ```
    """
    try:
        with open(file_name, "rb") as f:
            return list(f.read())
    except FileNotFoundError:
        print(f"Error: File '{file_name}' not found.")
        exit(1)
    except IOError as e:
        print(f"Error reading file '{file_name}': {e}")
        exit(1)


def format_bytes(all_bytes: List[int], bytes_per_line: int) -> List[str]:
    """
    Format a list of bytes into lines with reversed byte order.

    # Arguments
    - `all_bytes`: List of integers representing bytes to format.
    - `bytes_per_line`: Number of bytes per line in the output.

    # Returns
    A list of strings, where each string is a reversed, hexadecimal representation
    of a line of bytes.

    # Example
    ```python
    assert format_bytes([1, 2, 3, 4], 2) == ['0201', '0403']
    assert format_bytes([1, 2, 3], 2) == ['0201', '0300']
    ```
    """
    hex_strings = [format(b, '02x') for b in all_bytes]

    # Pad with "00" to make the total length a multiple of bytes_per_line
    padding = (bytes_per_line - len(hex_strings) % bytes_per_line) % bytes_per_line
    hex_strings.extend(["00"] * padding)

    results: List[str] = []
    for i in range(0, len(hex_strings), bytes_per_line):
        line = "".join(hex_strings[i + bytes_per_line - j - 1] for j in range(bytes_per_line))
        results.append(line)
    return results


def main() -> None:
    """
    Main function to execute the script.

    # Example
    ```python
    import sys
    from unittest.mock import patch

    sys.argv = ["script.py", "2", "test.bin"]

    with open("test.bin", "wb") as f:
        f.write(b'\x01\x02\x03\x04')

    with patch("builtins.print") as mock_print:
        main()
        mock_print.assert_called_with("0403\n0201")

    import os
    os.remove("test.bin")
    ```
    """
    bytes_per_line, file_name = parse_args(sys.argv[1:])
    all_bytes = read_binary_file(file_name)
    formatted_lines = format_bytes(all_bytes, bytes_per_line)
    print("\n".join(formatted_lines))


if __name__ == "__main__":
    main()
