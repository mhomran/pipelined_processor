import sys
import click

from io_lib import IO

def main():
    pass
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
    out_lines = lines

    # Write to file
    io_man.writeLineToFile(kwargs.get("out_file"), out_lines)

    # Close the open files
    io_man.closeOpenFiles()

    pass

if __name__ == "__main__.py" :
    args = sys.argv
    if len(args) == 1:
        print("Pipelined Assembler")
    main()
