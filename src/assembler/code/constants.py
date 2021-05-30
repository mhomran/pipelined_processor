from enum import Enum

class OpcodeType(Enum) :
    NO_OPD   =  0,
    SINGLE   =  1,
    DOUBLE   =  2,    
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
    

    # SINGLE OPERANDs & NOP
    'NOP'   : 0b01010,   # 0x0A
    'SETC'  : 0b01011,   # 0x0B
    'CLRC'  : 0b01100,   # 0x0C
    'CLR'   : 0b01101,   # 0x0D
    'NOT'   : 0b01110,   # 0x0E
    'INC'   : 0b01111,   # 0x0F
    'DEC'   : 0b10000,   # 0x10
    'NEG'   : 0b10001,   # 0x11
    'IN'    : 0b10010,   # 0x12
    'OUT'   : 0b10011,   # 0x13
    
    # MEMORY INSTRUCTIONS
    'LDM'   : 0b10100,   # 0x14
    'LDD'   : 0b10101,   # 0x15
    'STD'   : 0b10110,   # 0x16
}

OPCODE_NBITS = {
    OpcodeType.DOUBLE   : 8,
    OpcodeType.SINGLE   : 8,
    OpcodeType.NO_OPD   : 8
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
    OpcodeType.SINGLE,
    OpcodeType.NO_OPD
    #OpcodeType.JUMP,
    #OpcodeType.BRANCH
]

IMMEDIA_REGEX= r'^@'

REG_COUNT = 7
REG_BIT_COUNT = 4
PC_REG = 8
SP_REG = 9

REG_SUBREGEX = f"[Rr][0-{REG_COUNT}]"
REG_REGEX = f"(?<!\w)({REG_SUBREGEX})(?!\w)"
SYMBOL_NAME_REGEX = "[A-Za-z_]{1}[A-Za-z0-9_]*"
DEFINE_REGEX = r'^define$'
INDEX_MATCHER = r'[0-9]{1,}(?=\()'
IMMEDIATE_VALUE_MATCHER = r'(?<=#)[0-9]{1,}'
COMMENT_REGEX = r'#.*'


MODES = ["IMMEDIATE", "REGISTER" , "MEMORY"]

MODE_CODE = {
    "REGISTER" : 0,
    "MEMORY"   : 1,
    "IMMEDIATE": 2, 
}

MODE_REGEX = {
    "IMMEDIATE": r"^#[0-9].*$",
}