
from SingletonMeta import SingletonMeta

## Simple IO Class

class IO(metaclass=SingletonMeta):
    openFiles = []

    ## Open file and save it to openfiles
    def readFileIntoLines(self, file_name):
        f = open(file_name, 'r')
        self.openFiles.append(f)
        return f.readlines()
    
    ## Open out file and write 
    def writeLineToFile(self, file_name, lines):
        f = open(file_name, 'w')
        self.openFiles.append(f)
        f.writelines(lines)
    
    ## Close Opened File
    def closeOpenFiles(self):
        [f.close() for f in self.openFiles]