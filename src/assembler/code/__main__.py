import sys
import click

from io_lib import IO
import constants

def main():
    pass

def wordize(lines):
    """
    Parse and tokenize lines
    """
    for l in lines :
        print(l)

    words = []
    return words
    
# Main Command
@main.command()
@click.argument('in_file', required=True)
@click.argument('out_file', required=True)
def compile(**kwargs):
    # Initialize IO Manager
    io_man      = IO()
    
    # Read the given file into lines
    lines = io_man.readFileIntoLines(kwargs.get("in_file"))

    # Translate to binary codes
    out_lines = wordize(lines)

    # Write to file
    io_man.writeLineToFile(kwargs.get("out_file"), out_lines)

    # Close the open files
    io_man.closeOpenFiles()

    pass

if __name__ == "__main__.py" :
    args = sys.argv
    if len(args) == 3:
        print("Pipelined Assembler")
    main()
