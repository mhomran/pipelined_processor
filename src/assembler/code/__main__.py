import sys
from constants import PC_REG

from io_lib import IO
from tokenizer import Tokenizer
from pl_parser import Parser 
from word_Counter import WordCounter

def wordize(lines):
    """
    Parse and tokenize lines
    """
    PC_Position = 0
    parser      = Parser()
    tokenizer   = Tokenizer(PC_Position)
    words = []
    for l in lines :
        # The rstrip() method removes any trailing characters (characters at the end a string)
        # space is the default trailing character to remove
        if (l.rstrip()) :
            statement = parser.parseSentence(l)
            token_lists = tokenizer.tokenizeStatement(statement)
            for l in token_lists :    
                words.append(l) 
                 
    return words
    return
    
# Main Command

def compile(Kargs1,Kargs2):
    # Initialize IO Manager
    io_man      = IO()
    
    # Read the given file into lines
    lines = io_man.readFileIntoLines(Kargs1)

    # Translate to binary codes
    words = wordize(lines)
    out_lines = [''.join([str(token) for token in word[::-1]]) + '\n' for word in words ]
    

    print(Kargs2)
    # Write to file
    io_man.writeLineToFile(Kargs2, out_lines)

    # Close the open files
    io_man.closeOpenFiles()

    pass


args = sys.argv

if len(args) == 3:
    print("Pipelined Assembler")

compile(args[1],args[2])
