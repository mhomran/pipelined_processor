import sys

from io_lib import IO
from tokenizer import Tokenizer
from pl_parser import Parser 
from word_Counter import WordCounter

def main():
    pass

def wordize(lines):
    """
    Parse and tokenize lines
    """
    parser      = Parser()
    tokenizer   = Tokenizer()
    word_ctr    = WordCounter()
    words = []
    for l in lines :
        # The rstrip() method removes any trailing characters (characters at the end a string)
        # space is the default trailing character to remove
        if (l.rstrip()) :
            statement = parser.parseSentence(l, int(word_ctr))
            token_lists = tokenizer.tokenizeStatement(statement, int(word_ctr))
            for l in token_lists :
                if len(l) > 0 :
                    words.append(l)
                    word_ctr += 1    
    return words
    
# Main Command

def compile(**Kargs):
    # Initialize IO Manager
    io_man      = IO()
    
    # Read the given file into lines
    lines = io_man.readFileIntoLines(Kargs[0])

    # Translate to binary codes
    out_lines = wordize(lines)

    # Write to file
    io_man.writeLineToFile(Kargs[1], out_lines)

    # Close the open files
    io_man.closeOpenFiles()

    pass

if __name__ == "__main__.py" :
    args = sys.argv
    if len(args) == 3:
        print("Pipelined Assembler")
    compile(args[1:2])
