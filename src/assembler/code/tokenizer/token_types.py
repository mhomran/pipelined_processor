from enum import Enum
import constants
import stores

class Token():
    """
    Generic Representation of token information
    """
    code : int = None
    nbits : int = 16
    def __str__(self):
        return f'{int(self.code):0{self.nbits}b}';
        pass
    
    def getCode(self):
        return self.code;
        pass

    pass

class OpcodeToken(Token):
    """
    Represents tokens for opcode
    """
    typ : constants.OpcodeType = constants.OpcodeType.DEFAULT;
    
    def __init__(self, code, typ) :
        
        self.code = code
        self.typ = typ 
        self.nbits = constants.OPCODE_NBITS[self.typ]
        pass
    
    pass

class OperandToken(Token):
    """
    Represents first word of operand code
    """
    reg = 0
    def __init__(self, reg) :
        self.reg = reg
        self.code = reg
        self.nbits = 4
        pass

    pass

class ImmediateValueToken(Token):
    """
    Represents immediate value stored in second word of operand code
    """
    def __init__(self, code) :
        self.code = code
        pass
    pass
