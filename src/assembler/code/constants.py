from enum import Enum

class OpcodeType(Enum) :
    NOP      =  0,
    SINGLE   =  1,
    DOUBLE   =  2,    
    DEFAULT  = -1,
    ##BRANCH = 1,
    ##JUMP   = 4,
    pass


OPCODES_DICT = {
    # 2 OPERANDs  (1 to 7 , 10 , 20 to 22)
    'MOV'   : 0b01010,   # 0x0A
    'ADD'   : 0b00001,   # 0x01
    'SUB'   : 0b00010,   # 0x02
    'AND'   : 0b00011,   # 0x03
    'OR'    : 0b00100,   # 0x04
    'IADD'  : 0b00101,   # 0x05
    'SHL'   : 0b00110,   # 0x06 
    'SHR'   : 0b00111,   # 0x07 

    # SINGLE OPERANDs (13 to 19) & NO OPERANDs (0 , 8 , 9 , 11 , 12)
    'NOP'   : 0b00000,   # 0x00 NO OPERAND
    'RLC'   : 0b01000,   # 0x08 NO OPERAND
    'RRC'   : 0b01001,   # 0x09 NO OPERAND
    'SETC'  : 0b01011,   # 0x0B NO OPERAND
    'CLRC'  : 0b01100,   # 0x0C NO OPERAND
    'CLR'   : 0b01101,   # 0x0D SINGLE OPERAND
    'NOT'   : 0b01110,   # 0x0E SINGLE OPERAND
    'INC'   : 0b01111,   # 0x0F SINGLE OPERAND
    'DEC'   : 0b10000,   # 0x10 SINGLE OPERAND
    'NEG'   : 0b10001,   # 0x11 SINGLE OPERAND
    'IN'    : 0b10010,   # 0x12 SINGLE OPERAND
    'OUT'   : 0b10011,   # 0x13 SINGLE OPERAND
    
    # MEMORY INSTRUCTIONS (Double Operands)
    'LDM'   : 0b10100,   # 0x14
    'LDD'   : 0b10101,   # 0x15
    'STD'   : 0b10110,   # 0x16
}

OPCODE_NBITS = {
    OpcodeType.NOP      : 16,
    OpcodeType.DOUBLE   : 8, 
    OpcodeType.SINGLE   : 8,
    #OpcodeType.JUMP    : 
    #OpcodeType.BRANCH  : 
}

OPCODE_TYPE = [
    OpcodeType.NOP   , #0     
    OpcodeType.DOUBLE, #1
    OpcodeType.DOUBLE, #2
    OpcodeType.DOUBLE, #3
    OpcodeType.DOUBLE, #4
    OpcodeType.DOUBLE, #5
    OpcodeType.DOUBLE, #6
    OpcodeType.DOUBLE, #7
    OpcodeType.NOP   , #8
    OpcodeType.NOP   , #9
    OpcodeType.DOUBLE, #10
    OpcodeType.NOP, #11
    OpcodeType.NOP, #12
    OpcodeType.SINGLE, #13
    OpcodeType.SINGLE, #14
    OpcodeType.SINGLE, #15
    OpcodeType.SINGLE, #16
    OpcodeType.SINGLE, #17
    OpcodeType.SINGLE, #18
    OpcodeType.SINGLE, #19
    OpcodeType.DOUBLE, #20
    OpcodeType.DOUBLE, #21
    OpcodeType.DOUBLE, #22

     
    #OpcodeType.JUMP,
    #OpcodeType.BRANCH
]

ORG_REGEX = r'.ORG'
INT_REGEX= r'^\d+$'

REG_COUNT = 7
REG_BIT_COUNT = 4
PC_REG = 8
SP_REG = 9

REG_SUBREGEX = f"[Rr][0-{REG_COUNT}]"
REG_REGEX = f"(?<!\w)({REG_SUBREGEX})(?!\w)"
SYMBOL_NAME_REGEX = "[A-Za-z_]{1}[A-Za-z0-9_]*"
INDEX_MATCHER = r'[0-9]{1,}(?=\()'
IMMEDIATE_VALUE_MATCHER = r'^[A-Fa-f0-9]+$'
COMMENT_REGEX = r'#.*'
SEGMENT_REGEX = r'[A-Za-z0-9\.]+'


