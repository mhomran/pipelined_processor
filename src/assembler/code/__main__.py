import sys

from io_lib import IO
from tokenizer import Tokenizer
from pl_parser import Parser 

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
            
            token_lists , Location = tokenizer.tokenizeStatement(statement)
            
            for l in token_lists :  
                if len(l) == 2: 
                    words.append([Location[0][0] , l[0]]) 
                    words.append([Location[0][1] , l[1]]) 
                else:
                    words.append([Location[0] , l]) 
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

    out_lines = ''
    for word in words:
        out_lines += word[0] + ": " + word[1]+'\n'
       

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
