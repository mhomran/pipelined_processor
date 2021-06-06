import SingletonMeta
import constants
import tokenizer.token_types as token_types
import re

class Tokenizer(metaclass=SingletonMeta.SingletonMeta):
    def __init__(self,position):
        self.PC = position
        self.OrgPC = position
        
    def createOpcodeToken(self, assem_str):
        """
        Given assembly operation string, create a new token with the proper code and type
        """
        
        # Translate to code
        code = constants.OPCODES_DICT[assem_str.upper()]
        
        # Determine type of operation
        typ = constants.OPCODE_TYPE[code & 0x0FF]
        
        return token_types.OpcodeToken(code, typ)
        pass

    def createOperandToken(self, assem_str):
        """
        Given assembly string of operand, return array of tokens with the appropriate code for output and immediate value
        """
        reg = None
    
        reg_match = re.search(constants.REG_REGEX, assem_str)
        
        reg = int( reg_match.group()[1] )
                
        return token_types.OperandToken(reg)
        pass

    def createOperandTokens(self, assem_str):
        """
        Get all tokens requires to build operand
        """
        
        operand_first_token = self.createOperandToken(assem_str);           
        return operand_first_token 
    
    def tokenizeStatement(self, statement):
        words = []
        Location = []
        
        if (len(statement) == 0) : return words , -1  # Handle empty sentence case
       
        # .ORG
        if (re.match(constants.ORG_REGEX, statement[0])):
            x = int(statement[1], 16)
            self.PC  = x 
            Location.append( str(self.PC) )
            
        # INT After ORG
        elif len(statement) == 1 and re.match(constants.IMMEDIATE_VALUE_MATCHER, statement[0]) :
            x = int(statement[0], 16)
            
            words.append( [ '{0:016b}'.format(x >> 16) , '{0:016b}'.format( x & 0x0000FFFF) ]   )
            self.PC += 1
            
            Location.append( [str(self.PC-1) , str(self.PC)] )
            self.PC += 1
        
        # Operation
        else:
            
            opcode_token = self.createOpcodeToken(statement[0])
            code = ''
            
            # NOP
            if (opcode_token.typ == constants.OpcodeType.NOP):    
                code = '{0:08b}'.format(opcode_token.code)
                words.append( code + '{0:08b}'.format(0) )
                Location.append( str(self.PC) )
                self.PC += 1

            # SINGLE
            elif (opcode_token.typ == constants.OpcodeType.SINGLE):
                code += '{0:08b}'.format(opcode_token.code)

                opd_token = self.createOperandTokens(statement[1])
                code += '{0:04b}'.format(opd_token.code) + '{0:04b}'.format(opd_token.code)
                
                words.append( code  )
                Location.append( str(self.PC) )
                self.PC += 1
            
            # DOUBLE
            elif (opcode_token.typ == constants.OpcodeType.DOUBLE):
               
                code += '{0:08b}'.format(opcode_token.code)
                opd_token1 = self.createOperandTokens(statement[1])

                opd_token2 = None
                if re.match( constants.IMMEDIATE_VALUE_MATCHER , statement[2] ) :
                    x = int(statement[2], 16)
                    code += '{0:04b}'.format(opd_token1.code) + '{0:04b}'.format(opd_token1.code)      
                    self.PC += 1
                    codeImm = '{0:016b}'.format(x)
                    words.append( [code , codeImm] )
                    Location.append( [str(self.PC-1) , str(self.PC)] )
                    self.PC += 1
                    
                else:
                    opd_token2 = self.createOperandTokens(statement[2])
                    code += '{0:04b}'.format(opd_token2.code) + '{0:04b}'.format(opd_token1.code)     
                    words.append( code  )
                    Location.append( str(self.PC) )
                    self.PC += 1
        
        return words , Location
    pass