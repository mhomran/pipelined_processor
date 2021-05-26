library ieee;
use ieee.std_logic_1164.all;

entity cpu is
  generic (
    WORDSIZE         : integer := 16;
    REG_SIZE         : integer := 32;
    REG_NUM          : integer := 10;
    REG_ADDR         : integer := 4; --CEIL(LOG2(REG_NUM))
    RAM_ADDRESS_SIZE : integer := 11 --to get 2K words
  );
  port(
    clk         : in std_logic;
    rst         : in std_logic;
    input_port  : in std_logic_vector(REG_SIZE-1 downto 0);
    output_port : out std_logic_vector(REG_SIZE-1 downto 0)
  );  
end cpu;

architecture cpu_0 of cpu is

----------------------------------declaration----------------------------------
component reg is
  generic (WORDSIZE : integer := 32);
       port(
           clk : in std_logic; 
           rst : in std_logic; 
           en : in std_logic;
           d : in std_logic_vector(WORDSIZE-1 downto 0);
           q : out std_logic_vector(WORDSIZE-1 downto 0)
          );
end component;

--alu
component alu is
generic (WORDSIZE : integer := 16);
port (                 	
    A, B       : in  std_logic_vector(WORDSIZE-1 downto 0); 
    S          : in  std_logic_vector(3 downto 0);
    Cin        : in  std_logic;
    F          : out std_logic_vector(WORDSIZE-1 downto 0);
    SetC, ClrC : out std_logic;
    SetZ, ClrZ : out std_logic;
    SetN, ClrN : out std_logic
    );            		
end component;

--ram
component ram is
  generic(
    WORDSIZE : integer := 8;
    ADDRESS_SIZE : integer := 6
  );
  port(
    clk : in std_logic;
    we  : in std_logic;
    address : in  std_logic_vector(ADDRESS_SIZE-1 downto 0);
    datain  : in  std_logic_vector(WORDSIZE-1 downto 0);
    dataout : out std_logic_vector(WORDSIZE*2-1 downto 0)
    );
end component;

--control unit
component control_unit is
  generic (
    CONTROL_WORD_SIZE : integer := 10;
    OPCODE_SIZE       : integer := 5
  );
  port(
      opcode       : in std_logic_vector(OPCODE_SIZE-1 downto 0);
      control_word : out std_logic_vector(CONTROL_WORD_SIZE-1 downto 0)
    );  
end component;

constant OPCODE_SIZE       : integer := 5;
constant CONTROL_WORD_SIZE : integer := 10;
constant MemWrite_offset   : integer := CONTROL_WORD_SIZE - 1;
constant MemRead_offset    : integer := CONTROL_WORD_SIZE - 2;
constant ALU_offset        : integer := CONTROL_WORD_SIZE - 6;
constant IMM_offset        : integer := CONTROL_WORD_SIZE - 7;
constant IO_offset         : integer := CONTROL_WORD_SIZE - 8;
constant WBO_offset        : integer := CONTROL_WORD_SIZE - 9;
constant RegWrite_offset   : integer := CONTROL_WORD_SIZE - 10;

--register file
component register_file is
  generic (
    REG_SIZE   : integer := 32;
    INPUT_SIZE : integer := 3; --CEIL(LOG2(REG_NUM))
    REG_NUM    : integer := 8
  );
  port(
    clk      : in  std_logic;
    rst      : in  std_logic;
    
    src      : in  std_logic_vector(INPUT_SIZE-1 downto 0);
    dst      : in  std_logic_vector(INPUT_SIZE-1 downto 0);
    src_op   : out std_logic_vector(REG_SIZE-1 downto 0);
    dst_op   : out std_logic_vector(REG_SIZE-1 downto 0);
    
    data     : in  std_logic_vector(REG_SIZE-1 downto 0);
    wr_reg   : in  std_logic_vector(INPUT_SIZE-1 downto 0);
    RegWrite : in  std_logic
  );  
end component;

--Status register
component status_register is
  generic (
    REG_SIZE   : integer := 32
  );
  port(
    clk        : in  std_logic;
    rst        : in  std_logic;
    C          : out std_logic;
    SetC, ClrC : in  std_logic;
    Z          : out std_logic;
    SetZ, ClrZ : in  std_logic;
    N          : out std_logic;
    SetN, ClrN : in  std_logic
  );  
end component;

---------------------------------signals---------------------------------------
--constants
constant INSTRUCTION_SIZE         : integer := WORDSIZE*2;
constant IMMEDIATE_VAL_SIZE       : integer := WORDSIZE;
constant ALU_SEL_SIZE             : integer := 4;
constant MEM_STAGE_CS             : integer := 3;
constant IF_ID_IMM_OFFSET         : integer := 0;
constant IF_ID_SRC_OFFSET         : integer := IF_ID_IMM_OFFSET+WORDSIZE;
constant IF_ID_DST_OFFSET         : integer := IF_ID_SRC_OFFSET+REG_ADDR;
constant IF_ID_OPCODE_OFFSET      : integer := IF_ID_DST_OFFSET+REG_ADDR;
constant CW_NOP                   : std_logic_vector(CONTROL_WORD_SIZE-1
 downto 0) :=  "0000000000";

constant ID_EX_RDST_OFFSET        : integer := 0;
constant ID_EX_DST_REG_OFFSET     : integer := ID_EX_RDST_OFFSET+REG_ADDR;
constant ID_EX_SRC_REG_OFFSET     : integer := ID_EX_DST_REG_OFFSET+REG_SIZE;
constant ID_EX_IMM_VAL_OFFSET     : integer := ID_EX_SRC_REG_OFFSET+REG_SIZE;
constant ID_EX_CTRL_SIG_OFFSET    : integer := ID_EX_IMM_VAL_OFFSET+
CONTROL_WORD_SIZE;
constant ID_EX_REGWRITE_OFFSET    : integer := ID_EX_CTRL_SIG_OFFSET;
constant ID_EX_WBO_OFFSET         : integer := ID_EX_REGWRITE_OFFSET+1;
constant ID_EX_IO_OFFSET          : integer := ID_EX_WBO_OFFSET+1;
constant ID_EX_IMM_OFFSET         : integer := ID_EX_IO_OFFSET+1;
constant ID_EX_ALU_OFFSET         : integer := ID_EX_IMM_OFFSET+1;
constant ID_EX_MEMREAD_OFFSET     : integer := ID_EX_ALU_OFFSET+ALU_SEL_SIZE;
constant ID_EX_MEMWRITE_OFFSET    : integer := ID_EX_MEMREAD_OFFSET+1;

constant EX_MEM_RDST_OFFSET       : integer := 0;
constant EX_MEM_DST_REG_OFFSET    : integer := EX_MEM_RDST_OFFSET+REG_ADDR;
constant EX_MEM_ALU_OUTPUT_OFFSET : integer := EX_MEM_DST_REG_OFFSET+REG_SIZE;
constant EX_MEM_REGWRITE_OFFSET   : integer := EX_MEM_ALU_OUTPUT_OFFSET+REG_SIZE;
constant EX_MEM_WBO_OFFSET        : integer := EX_MEM_REGWRITE_OFFSET+1;
constant EX_MEM_IO_OFFSET         : integer := EX_MEM_WBO_OFFSET+1;
constant EX_MEM_MEMREAD_OFFSET    : integer := EX_MEM_IO_OFFSET+1;
constant EX_MEM_MEMWRITE_OFFSET   : integer := EX_MEM_MEMREAD_OFFSET+1;

constant MEM_WB_RDST_OFFSET       : integer := 0;
constant MEM_WB_ALU_OUTPUT_OFFSET : integer := MEM_WB_RDST_OFFSET+REG_ADDR;
constant MEM_WB_MEM_OUTPUT_OFFSET : integer := MEM_WB_ALU_OUTPUT_OFFSET+REG_SIZE;
constant MEM_WB_REGWRITE_OFFSET   : integer := MEM_WB_MEM_OUTPUT_OFFSET+1;
constant MEM_WB_WBO_OFFSET        : integer := MEM_WB_REGWRITE_OFFSET+1;

--Intermediate registers
signal IF_ID_input  : std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal IF_ID_output : std_logic_vector(IF_ID_input'length downto 0);
signal IF_ID_en     : std_logic;

signal ID_EX_input  : std_logic_vector(
((CONTROL_WORD_SIZE + IMMEDIATE_VAL_SIZE + 2*REG_SIZE + REG_ADDR)-1) downto 0);
signal ID_EX_output : std_logic_vector(ID_EX_input'length downto 0);
signal ID_EX_en     : std_logic;

signal EX_MEM_input  : std_logic_vector(
((CONTROL_WORD_SIZE-ALU_SEL_SIZE-MEM_STAGE_CS + 2*REG_SIZE + REG_ADDR)-1)
 downto 0);
signal EX_MEM_output : std_logic_vector(EX_MEM_input'length downto 0);
signal EX_MEM_en     : std_logic;

signal MEM_WB_input  : std_logic_vector(
((CONTROL_WORD_SIZE-ALU_SEL_SIZE + 2*REG_SIZE + REG_ADDR)-1) downto 0);
signal MEM_WB_output : std_logic_vector(MEM_WB_input'length downto 0);
signal MEM_WB_en     : std_logic;

--control unit
signal WBO      : std_logic;
signal RegWrite : std_logic;
signal MemWrite : std_logic;
signal MemRead  : std_logic;

--register file
signal RegFileSrc_output : std_logic_vector(REG_SIZE-1 downto 0);
signal RegFileDst_output : std_logic_vector(REG_SIZE-1 downto 0);
signal RegFileWDst_input : std_logic_vector(REG_SIZE-1 downto 0);
signal RegFileWDst       : std_logic_vector(REG_ADDR-1 downto 0);

--RAM
signal RAM_address  : std_logic_vector(RAM_ADDRESS_SIZE-1 downto 0);
signal RAM_input    : std_logic_vector(WORDSIZE*2-1 downto 0);
signal RAM_output   : std_logic_vector(WORDSIZE*2-1 downto 0);
signal MemUse       : std_logic;

--ALU
signal ALU_op1        : std_logic_vector(WORDSIZE*2-1 downto 0);
signal ALU_op2        : std_logic_vector(WORDSIZE*2-1 downto 0);
signal ALU_output     : std_logic_vector(WORDSIZE*2-1 downto 0);
signal ALU_sel        : std_logic_vector(ALU_SEL_SIZE-1 downto 0);
signal C, SetC, ClrC  : std_logic;
signal Z, SetZ, ClrZ  : std_logic;
signal N, SetN, ClrN  : std_logic;

--PC
signal PC_input_en    : std_logic;
signal PC_input       : std_logic_vector(REG_SIZE-1 downto 0);
signal PC_output      : std_logic_vector(REG_SIZE-1 downto 0);

--IO registers
signal IN_PORT_output : std_logic_vector(REG_SIZE-1 downto 0);
signal OUT_PORT_input : std_logic_vector(REG_SIZE-1 downto 0);

--sign extender
signal IMM_VAL_extended : std_logic_vector(REG_SIZE-1 downto 0);

--control unit
signal control_unit_output : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0);



begin
---------------------------------Register file---------------------------------
RegFile: 
register_file generic map(REG_SIZE, REG_ADDR, REG_NUM)
port map(
  clk, rst, 

  IF_ID_output((REG_SIZE+IF_ID_SRC_OFFSET) downto IF_ID_SRC_OFFSET), 
  IF_ID_output((REG_SIZE+IF_ID_DST_OFFSET) downto IF_ID_DST_OFFSET), 
  RegFileSrc_output, 
  RegFileDst_output, 

  RegFileWDst_input, RegFileWDst,
  MEM_WB_output(MEM_WB_output'length - 2)
  );

RegFileWDst <= MEM_WB_output(REG_ADDR-1 downto 0);
RegFileWDst_input <= MEM_WB_output(REG_SIZE+REG_ADDR-1 downto REG_ADDR)
when MEM_WB_output(MEM_WB_output'length - 1) = '1'
else MEM_WB_output(2*REG_SIZE+REG_ADDR-1 downto REG_SIZE+REG_ADDR);
-----------------------------------PC------------------------------------------
PC: reg generic map (REG_SIZE) 
port map(clk, rst, PC_input_en, PC_input, PC_output);  
-----------------------------------RAM-----------------------------------------
RAM_inst:
ram generic map(WORDSIZE, RAM_ADDRESS_SIZE)
port map(clk, MemWrite, RAM_address, RAM_input, RAM_output);

MemUse <= MemWrite or MemRead;

RAM_address <= EX_MEM_output(EX_MEM_ALU_OUTPUT_OFFSET+REG_SIZE-1 downto 
EX_MEM_ALU_OUTPUT_OFFSET) when MemUse = '1' else PC_output;

RAM_input <= EX_MEM_output(EX_MEM_DST_REG_OFFSET+REG_SIZE-1 downto 
EX_MEM_DST_REG_OFFSET);
-----------------------------------IO registers--------------------------------

IN_PORT: reg generic map (REG_SIZE) 
port map(clk, rst, '1', input_port, IN_PORT_output); 

OUT_PORT: reg generic map (REG_SIZE) 
port map(clk, rst, EX_MEM_output(EX_MEM_IO_OFFSET), OUT_PORT_input, output_port); 

-----------------------------------ALU-----------------------------------------
ALU_inst:
alu generic map(REG_SIZE)
port map(ALU_op1, ALU_op2, ALU_sel, C, ALU_output, SetC, ClrC, SetZ, ClrZ,
 SetN, ClrN);
------------------------------Status register----------------------------------
SR: 
status_register port map(clk, rst, C, SetC, ClrC, Z, SetZ, ClrZ, N, SetN, ClrN);
------------------------------Control signals----------------------------------
ControlUnit:
control_unit generic map(CONTROL_WORD_SIZE, OPCODE_SIZE)
port map(IF_ID_output(IF_ID_OPCODE_OFFSET+CONTROL_WORD_SIZE-1 downto
IF_ID_OPCODE_OFFSET), control_unit_output);
---------------------------------Intermediate registers------------------------
IF_ID: 
reg generic map (IF_ID_input'length) 
port map(clk, rst, IF_ID_en, IF_ID_input, IF_ID_output);  

IF_ID_input <= RAM_output when MemUse = '0' else CW_NOP;

ID_EX: 
reg generic map (ID_EX_input'length) 
port map(clk, rst, ID_EX_en, ID_EX_input, ID_EX_output);  

ID_EX_input(ID_EX_RDST_OFFSET+REG_ADDR-1 downto ID_EX_RDST_OFFSET) <= 
IF_ID_output((REG_SIZE+IF_ID_DST_OFFSET) downto IF_ID_DST_OFFSET);

ID_EX_input(ID_EX_DST_REG_OFFSET+REG_SIZE-1 downto ID_EX_DST_REG_OFFSET) <= 
RegFileDst_output;

ID_EX_input(ID_EX_SRC_REG_OFFSET+REG_SIZE-1 downto ID_EX_SRC_REG_OFFSET) <=
RegFileSrc_output;

ID_EX_input(ID_EX_IMM_VAL_OFFSET+REG_SIZE-1 downto ID_EX_IMM_VAL_OFFSET) <=
IMM_VAL_extended;


IMM_VAL_extended(WORDSIZE-1 downto 0) <= IF_ID_output(WORDSIZE+IF_ID_IMM_OFFSET-1 
downto IF_ID_IMM_OFFSET);
IMM_VAL_extended(2*WORDSIZE-1 downto WORDSIZE) <= (others => '1') when 
IF_ID_output(WORDSIZE+IF_ID_IMM_OFFSET-1) = '1' else (others => '0');

ID_EX_input(ID_EX_CTRL_SIG_OFFSET+WORDSIZE-1 downto ID_EX_CTRL_SIG_OFFSET) <=
control_unit_output;

EX_MEM: 
reg generic map (EX_MEM_input'length) 
port map(clk, rst, EX_MEM_en, EX_MEM_input, EX_MEM_output);  

EX_MEM_input(EX_MEM_RDST_OFFSET+REG_ADDR-1 downto EX_MEM_RDST_OFFSET) <=
ID_EX_output(ID_EX_RDST_OFFSET+ REG_ADDR-1 downto ID_EX_RDST_OFFSET);

EX_MEM_input(EX_MEM_DST_REG_OFFSET+REG_ADDR-1 downto EX_MEM_DST_REG_OFFSET) <=
ID_EX_output(ID_EX_DST_REG_OFFSET+REG_ADDR-1 downto ID_EX_DST_REG_OFFSET);

EX_MEM_input(EX_MEM_ALU_OUTPUT_OFFSET+REG_ADDR-1 downto EX_MEM_ALU_OUTPUT_OFFSET) <=
ALU_output;

EX_MEM_input(EX_MEM_REGWRITE_OFFSET) <= ID_EX_output(ID_EX_REGWRITE_OFFSET);
EX_MEM_input(EX_MEM_WBO_OFFSET)      <= ID_EX_output(ID_EX_WBO_OFFSET);
EX_MEM_input(EX_MEM_IO_OFFSET)       <= ID_EX_output(ID_EX_IO_OFFSET);
EX_MEM_input(EX_MEM_MEMREAD_OFFSET)  <= ID_EX_output(ID_EX_MEMREAD_OFFSET);
EX_MEM_input(EX_MEM_MEMWRITE_OFFSET) <= ID_EX_output(ID_EX_MEMWRITE_OFFSET);

MEM_WB: 
reg generic map (MEM_WB_input'length) 
port map(clk, rst, MEM_WB_en, MEM_WB_input, MEM_WB_output);  

MEM_WB_input(MEM_WB_RDST_OFFSET+REG_ADDR-1 downto MEM_WB_RDST_OFFSET) <= 
EX_MEM_output(EX_MEM_RDST_OFFSET+REG_ADDR-1 downto EX_MEM_RDST_OFFSET);

MEM_WB_input(MEM_WB_MEM_OUTPUT_OFFSET+REG_SIZE-1 downto MEM_WB_MEM_OUTPUT_OFFSET) <= 
RAM_output when EX_MEM_output(EX_MEM_IO_OFFSET) = '0'
else IN_PORT_output;

MEM_WB_input(MEM_WB_ALU_OUTPUT_OFFSET+REG_SIZE-1 downto MEM_WB_ALU_OUTPUT_OFFSET) <=
EX_MEM_output(EX_MEM_ALU_OUTPUT_OFFSET+REG_SIZE-1 downto EX_MEM_ALU_OUTPUT_OFFSET);

MEM_WB_input(MEM_WB_WBO_OFFSET) <= EX_MEM_output(EX_MEM_WBO_OFFSET);
MEM_WB_input(MEM_WB_REGWRITE_OFFSET) <= EX_MEM_output(EX_MEM_REGWRITE_OFFSET);

end architecture cpu_0;

