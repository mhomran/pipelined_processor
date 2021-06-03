from enum import Enum

class OpcodeType(Enum) :
    NOP      =  0,
    SINGLE   =  1,
    DOUBLE   =  2,   
    MEMORY   =  3,   
    DEFAULT  = -1,
    ##BRANCH = 1,
    ##JUMP   = 4,
    pass


OPCODES_DICT = {
    # 2 OPERANDs 
    'MOV'   : 0b00000,   # 0x00
    'ADD'   : 0b00001,   # 0x01
    'SUB'   : 0b00010,   # 0x02
    'AND'   : 0b00011,   # 0x03
    'OR'    : 0b00100,   # 0x04
    'IADD'  : 0b00101,   # 0x05
    'SHL'   : 0b00110,   # 0x06
    'SHR'   : 0b00111,   # 0x07
    'RLC'   : 0b01000,   # 0x08
    'RRC'   : 0b01001,   # 0x09
    

    # SINGLE OPERANDs & NO OPERANDs
    'NOP'   : 0b01010,   # 0x0A NO OPERAND
    'SETC'  : 0b01011,   # 0x0B NO OPERAND
    'CLRC'  : 0b01100,   # 0x0C NO OPERAND
    'CLR'   : 0b01101,   # 0x0D SINGLE OPERAND
    'NOT'   : 0b01110,   # 0x0E SINGLE OPERAND
    'INC'   : 0b01111,   # 0x0F SINGLE OPERAND
    'DEC'   : 0b10000,   # 0x10 SINGLE OPERAND
    'NEG'   : 0b10001,   # 0x11 SINGLE OPERAND
    'IN'    : 0b10010,   # 0x12 SINGLE OPERAND
    'OUT'   : 0b10011,   # 0x13 SINGLE OPERAND
    
    # MEMORY INSTRUCTIONS
    'LDM'   : 0b10100,   # 0x14
    'LDD'   : 0b10101,   # 0x15
    'STD'   : 0b10110,   # 0x16
}

OPCODE_NBITS = {
    OpcodeType.NOP      : 16,
    OpcodeType.DOUBLE   : 8, 
    OpcodeType.SINGLE   : 8,
    OpcodeType.MEMORY   : 8
    #OpcodeType.JUMP    : 
    #OpcodeType.BRANCH  : 
}

OPCODE_TYPE = [
    OpcodeType.DOUBLE,
    OpcodeType.DOUBLE,
    OpcodeType.DOUBLE,
    OpcodeType.DOUBLE,
    OpcodeType.DOUBLE,
    OpcodeType.DOUBLE,
    OpcodeType.DOUBLE,
    OpcodeType.DOUBLE,
    OpcodeType.DOUBLE,
    OpcodeType.DOUBLE,
    OpcodeType.NOP,
    OpcodeType.NOP,
    OpcodeType.NOP,
    OpcodeType.SINGLE,
    OpcodeType.SINGLE,
    OpcodeType.SINGLE,
    OpcodeType.SINGLE,
    OpcodeType.SINGLE,
    OpcodeType.SINGLE,
    OpcodeType.SINGLE,
    OpcodeType.MEMORY,
    OpcodeType.MEMORY,
    OpcodeType.MEMORY
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
IMMEDIATE_VALUE_MATCHER = r'(?<=#)[0-9]{1,}'
COMMENT_REGEX = r'#.*'
SEGMENT_REGEX = r'[A-Za-z0-9\.]+'


MODES = ["IMMEDIATE", "REGISTER" , "MEMORY"]

MODE_CODE = {
    "REGISTER" : 0,
    "MEMORY"   : 1,
    "IMMEDIATE": 2, 
}

MODE_REGEX = {
    "IMMEDIATE": r"^#[0-9].*$",
}