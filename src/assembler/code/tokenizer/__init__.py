import SingletonMeta
import constants
import tokenizer.token_types as token_types
import re
import stores

class Tokenizer(metaclass=SingletonMeta.SingletonMeta):
    def __init__(self,position):
        self.PC = position
        
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
        operand_extra_token = None
        
        
        # IMMEDIATE
        '''
        if (operand_first_token.code == constants.MODE_CODE["IMMEDIATE"]):
            imm_val = int(re.search(constants.IMMEDIATE_VALUE_MATCHER, assem_str).group())
            operand_extra_token = token_types.ImmediateValueToken(imm_val)'''
        
        return operand_first_token, operand_extra_token
    
    def tokenizeStatement(self, statement):
        words = [[],[]]

        if (len(statement) == 0) : return words  # Handle empty sentence case
        
        # .ORG
        if (re.match(constants.ORG_REGEX, statement[0], flags=re.IGNORECASE)):
            
            orgJump = int(statement[1]) - self.PC 
            i=0
            while i < orgJump :
                words[0].append( '{0:016b}'.format(0) )
                i+=1
            self.PC = int(statement[1])

        # INT After ORG
        elif re.match(constants.INT_REGEX, statement[0]) :
            words[0].append( '{0:016b}'.format( int(statement[0]) ) )
            self.PC += 1
        
        # Operation
        else:
            
            opcode_token = self.createOpcodeToken(statement[0])
            words[0].append(opcode_token)
        
            # SINGLE
            if (opcode_token.typ == constants.OpcodeType.SINGLE):
                opd_token, ext_token = self.createOperandTokens(statement[1])
                words[0].append(opd_token)
                if (ext_token):
                    words[1].append(ext_token)
            
            # DOUBLE
            elif (opcode_token.typ == constants.OpcodeType.DOUBLE):
                for i in range(1,3) :
                    opd_token, ext_token = self.createOperandTokens(statement[i])
                    words[0].append(opd_token)
                    if (ext_token):
                        words[1].append(ext_token)
            self.PC += 1
        
        return words
    pass