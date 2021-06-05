library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

-- sp_reg
component sp_reg is
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
    S          : in  std_logic_vector(4 downto 0);
    Cin        : in  std_logic;
    F          : inout std_logic_vector(WORDSIZE-1 downto 0);
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
constant CONTROL_WORD_SIZE : integer := 11;
constant Write_offset   : integer := CONTROL_WORD_SIZE - 1;
constant Read_offset    : integer := CONTROL_WORD_SIZE - 2;
constant ALU_offset        : integer := CONTROL_WORD_SIZE - 6;
constant IMM_offset        : integer := CONTROL_WORD_SIZE - 7;
constant IO_offset         : integer := CONTROL_WORD_SIZE - 8;
constant WBO_offset        : integer := CONTROL_WORD_SIZE - 9;
constant RegWrite_offset   : integer := CONTROL_WORD_SIZE - 10;

--register file
component register_file is
  generic (
    REG_SIZE   : integer := 32;
    REG_ADDR   : integer := 3; --CEIL(LOG2(REG_NUM))
    REG_NUM    : integer := 8
  );
  port(
    clk      : in  std_logic;
    rst      : in  std_logic;
    
    src      : in  std_logic_vector(REG_ADDR-1 downto 0);
    dst      : in  std_logic_vector(REG_ADDR-1 downto 0);
    src_op   : out std_logic_vector(REG_SIZE-1 downto 0);
    dst_op   : out std_logic_vector(REG_SIZE-1 downto 0);
    
    data     : in  std_logic_vector(REG_SIZE-1 downto 0);
    wr_reg   : in  std_logic_vector(REG_ADDR-1 downto 0);
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

-- Ripple Adder
component ripple_adder is
  generic (
    SIZE : integer := 32
    );
	port (
    op1, op2 : in std_logic_vector(SIZE-1 downto 0);
    cin : in std_logic;
    result : out  std_logic_vector(SIZE-1 downto 0);
    cout : out std_logic
    );
end component;
---------------------------------signals---------------------------------------
--constants
constant NOP_CONTROL_WORD         : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "00000000000";

constant INSTRUCTION_SIZE         : integer := REG_SIZE;
constant IMMEDIATE_VAL_SIZE       : integer := REG_SIZE;
constant ALU_SEL_SIZE             : integer := 5;
constant IF_ID_IMM_OFFSET         : integer := 0;
constant IF_ID_SRC_OFFSET         : integer := IF_ID_IMM_OFFSET+WORDSIZE;
constant IF_ID_DST_OFFSET         : integer := IF_ID_SRC_OFFSET+REG_ADDR;
constant IF_ID_OPCODE_OFFSET      : integer := IF_ID_DST_OFFSET+REG_ADDR;
constant IF_ID_INSTRUCTION_NOP    : std_logic_vector(INSTRUCTION_SIZE-1 downto 0) :=  "00000000000000000000000000000000";

constant ID_EX_RDST_OFFSET        : integer := 0;
constant ID_EX_DST_REG_OFFSET     : integer := ID_EX_RDST_OFFSET+REG_ADDR;
constant ID_EX_SRC_REG_OFFSET     : integer := ID_EX_DST_REG_OFFSET+REG_SIZE;
constant ID_EX_IMM_VAL_OFFSET     : integer := ID_EX_SRC_REG_OFFSET+REG_SIZE;
constant ID_EX_CTRL_SIG_OFFSET    : integer := ID_EX_IMM_VAL_OFFSET+REG_SIZE;
constant ID_EX_REGWRITE_OFFSET    : integer := ID_EX_CTRL_SIG_OFFSET;
constant ID_EX_WBO_OFFSET         : integer := ID_EX_REGWRITE_OFFSET+1;
constant ID_EX_IO_OFFSET          : integer := ID_EX_WBO_OFFSET+1;
constant ID_EX_IMM_OFFSET         : integer := ID_EX_IO_OFFSET+1;
constant ID_EX_ALU_OFFSET         : integer := ID_EX_IMM_OFFSET+1;
constant ID_EX_READ_OFFSET        : integer := ID_EX_ALU_OFFSET+ALU_SEL_SIZE;
constant ID_EX_WRITE_OFFSET       : integer := ID_EX_READ_OFFSET+1;
constant ID_EX_RSRC_OFFSET        : integer := ID_EX_WRITE_OFFSET+1;

constant EX_MEM_RDST_OFFSET       : integer := 0;
constant EX_MEM_DST_REG_OFFSET    : integer := EX_MEM_RDST_OFFSET+REG_ADDR;
constant EX_MEM_ALU_OUTPUT_OFFSET : integer := EX_MEM_DST_REG_OFFSET+REG_SIZE;
constant EX_MEM_REGWRITE_OFFSET   : integer := EX_MEM_ALU_OUTPUT_OFFSET+REG_SIZE;
constant EX_MEM_WBO_OFFSET        : integer := EX_MEM_REGWRITE_OFFSET+1;
constant EX_MEM_IO_OFFSET         : integer := EX_MEM_WBO_OFFSET+1;
constant EX_MEM_READ_OFFSET       : integer := EX_MEM_IO_OFFSET+1;
constant EX_MEM_WRITE_OFFSET      : integer := EX_MEM_READ_OFFSET+1;
constant EX_MEM_IMM_OFFSET        : integer := EX_MEM_WRITE_OFFSET+1;

constant MEM_WB_RDST_OFFSET       : integer := 0;
constant MEM_WB_ALU_OUTPUT_OFFSET : integer := MEM_WB_RDST_OFFSET+REG_ADDR;
constant MEM_WB_MEM_OUTPUT_OFFSET : integer := MEM_WB_ALU_OUTPUT_OFFSET+REG_SIZE;
constant MEM_WB_REGWRITE_OFFSET   : integer := MEM_WB_MEM_OUTPUT_OFFSET+REG_SIZE;
constant MEM_WB_WBO_OFFSET        : integer := MEM_WB_REGWRITE_OFFSET+1;

--constant OPCODE_SIZE  : integer := 5; 
constant OC_LDD  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "10101";
constant OC_STD  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "10110";
constant OC_LDM  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "10100"; 
constant OC_IADD : std_logic_vector(OPCODE_SIZE-1 downto 0) := "00101";
constant OC_SHL  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "00110";
constant OC_SHR  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "00111";

--Intermediate registers
signal IF_ID_input   : std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal IF_ID_output  : std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal IF_ID_en      : std_logic;

signal ID_EX_input   : std_logic_vector(
((CONTROL_WORD_SIZE + IMMEDIATE_VAL_SIZE + 2*REG_SIZE + 2*REG_ADDR)-1) downto 0);
signal ID_EX_output  : std_logic_vector(ID_EX_input'length-1 downto 0);
signal ID_EX_en      : std_logic;
constant ID_EX_INSTRUCTION_NOP    : std_logic_vector(ID_EX_input'length-1 downto 0) := "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

signal EX_MEM_input  : std_logic_vector(((CONTROL_WORD_SIZE-ALU_SEL_SIZE + 2*REG_SIZE + REG_ADDR)-1) downto 0);
signal EX_MEM_output : std_logic_vector(EX_MEM_input'length-1 downto 0);
signal EX_MEM_en     : std_logic;

signal MEM_WB_input  : std_logic_vector(
((CONTROL_WORD_SIZE-ALU_SEL_SIZE-4 + 2*REG_SIZE + REG_ADDR)-1) downto 0);
signal MEM_WB_output : std_logic_vector(MEM_WB_input'length-1 downto 0);
signal MEM_WB_en     : std_logic;

--control unit
signal WBO      : std_logic;
signal RegWrite : std_logic;

--register file
signal RegFileSrc_output : std_logic_vector(REG_SIZE-1 downto 0);
signal RegFileDst_output : std_logic_vector(REG_SIZE-1 downto 0);
signal RegFileWDst_input : std_logic_vector(REG_SIZE-1 downto 0);
signal RegFileWDst       : std_logic_vector(REG_ADDR-2 downto 0);

--RAM
signal RAM_address  : std_logic_vector(RAM_ADDRESS_SIZE-1 downto 0);
signal RAM_input    : std_logic_vector(WORDSIZE*2-1 downto 0);
signal RAM_input_en : std_logic;
signal RAM_output   : std_logic_vector(WORDSIZE*2-1 downto 0);
signal MemUse       : std_logic;

--ALU
signal ALU_op1        : std_logic_vector(WORDSIZE*2-1 downto 0);
signal ALU_op1_mux1   : std_logic_vector(WORDSIZE*2-1 downto 0);
signal ALU_op2        : std_logic_vector(WORDSIZE*2-1 downto 0);
signal ALU_output     : std_logic_vector(WORDSIZE*2-1 downto 0);
signal ALU_sel        : std_logic_vector(ALU_SEL_SIZE-1 downto 0);
signal C, SetC, ClrC  : std_logic;
signal Z, SetZ, ClrZ  : std_logic;
signal N, SetN, ClrN  : std_logic;

--PC
signal PC_input_en    : std_logic;
signal PC_input       : std_logic_vector(REG_SIZE-1 downto 0);
signal PC_RA_output   : std_logic_vector(REG_SIZE-1 downto 0);
signal PC_output      : std_logic_vector(REG_SIZE-1 downto 0);
signal is_imm_instruction : std_logic;
signal PC_increment   : std_logic_vector(REG_SIZE-1 downto 0);
signal PC_carry       : std_logic;

--IO registers
signal IN_PORT_output : std_logic_vector(REG_SIZE-1 downto 0);
signal OUT_PORT_input : std_logic_vector(REG_SIZE-1 downto 0);
signal OUT_PORT_en    : std_logic;

--sign extender
signal IMM_VAL_extended : std_logic_vector(REG_SIZE-1 downto 0);

--control unit
signal control_unit_output : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0);

--load use case
signal EX_MEM_Use_Memory   : std_logic;

--Forwarding unit
signal EX_to_EX_Forwarding_Src  : std_logic;
signal EX_to_EX_Forwarding_Dst  : std_logic;
signal MEM_to_EX_Forwarding_Src : std_logic;
signal MEM_to_EX_Forwarding_Dst : std_logic;
signal Forward_Src              : std_logic;
signal Forward_Dst              : std_logic;
signal SRC_Equals_EX_Dst        : std_logic;
signal SRC_Equals_MEM_Dst       : std_logic;
signal DST_Equals_EX_Dst        : std_logic;
signal DST_Equals_MEM_Dst       : std_logic;

-- Load Use
signal Load_Use                 : std_logic;
signal Load_Use_Case            : std_logic;

-- SP
signal SP_carry                 : std_logic;
signal SP_en                    : std_logic; 
signal SP_input                 : std_logic_vector(REG_SIZE-1 downto 0); 
signal SP_output                : std_logic_vector(REG_SIZE-1 downto 0); 
signal SP_added                 : std_logic_vector(REG_SIZE-1 downto 0); 


begin
---------------------------------Register file---------------------------------
RegFile: 
register_file generic map(REG_SIZE, REG_ADDR-1, REG_NUM-2)
port map(
  clk,
  rst, 

  IF_ID_output((IF_ID_SRC_OFFSET+REG_ADDR-2) downto IF_ID_SRC_OFFSET), 
  IF_ID_output((IF_ID_DST_OFFSET+REG_ADDR-2) downto IF_ID_DST_OFFSET), 
  RegFileSrc_output, 
  RegFileDst_output, 

  RegFileWDst_input, 
  RegFileWDst,
  MEM_WB_output(MEM_WB_REGWRITE_OFFSET)
  );

RegFileWDst <= MEM_WB_output(MEM_WB_RDST_OFFSET+REG_ADDR-2 downto MEM_WB_RDST_OFFSET);

RegFileWDst_input <= MEM_WB_output(MEM_WB_MEM_OUTPUT_OFFSET+REG_SIZE-1 downto 
MEM_WB_MEM_OUTPUT_OFFSET) 
when MEM_WB_output(MEM_WB_WBO_OFFSET) = '1'
else MEM_WB_output(MEM_WB_ALU_OUTPUT_OFFSET+REG_SIZE-1 downto
MEM_WB_ALU_OUTPUT_OFFSET);
-----------------------------------PC------------------------------------------
PC: reg generic map (REG_SIZE) 
port map(clk, '0', PC_input_en, PC_input, PC_output);  
PC_input_en <= rst or not (EX_MEM_Use_Memory or Load_Use);

is_imm_instruction <= '1' 
when 
RAM_output(IF_ID_OPCODE_OFFSET+OPCODE_SIZE-1 downto IF_ID_OPCODE_OFFSET) = OC_LDD or
RAM_output(IF_ID_OPCODE_OFFSET+OPCODE_SIZE-1 downto IF_ID_OPCODE_OFFSET) = OC_STD or
RAM_output(IF_ID_OPCODE_OFFSET+OPCODE_SIZE-1 downto IF_ID_OPCODE_OFFSET) = OC_LDM or
RAM_output(IF_ID_OPCODE_OFFSET+OPCODE_SIZE-1 downto IF_ID_OPCODE_OFFSET) = OC_IADD or
RAM_output(IF_ID_OPCODE_OFFSET+OPCODE_SIZE-1 downto IF_ID_OPCODE_OFFSET) = OC_SHL or
RAM_output(IF_ID_OPCODE_OFFSET+OPCODE_SIZE-1 downto IF_ID_OPCODE_OFFSET) = OC_SHR 
else '0';

PC_increment <= std_logic_vector(to_unsigned(2, REG_SIZE)) 
when is_imm_instruction = '1' 
else std_logic_vector(to_unsigned(1, REG_SIZE));

ADDER_inst:
ripple_adder generic map(REG_SIZE)
port map(PC_output, PC_increment, '0', PC_RA_output, PC_carry);

PC_input <= RAM_output when rst = '1' else PC_RA_output;
-----------------------------------RAM-----------------------------------------
RAM_inst:
ram generic map(WORDSIZE, RAM_ADDRESS_SIZE)
port map(clk, RAM_input_en, RAM_address, RAM_input, RAM_output);

RAM_input_en <= EX_MEM_output(EX_MEM_WRITE_OFFSET) and not 
EX_MEM_output(EX_MEM_IO_OFFSET);

RAM_address <= (others=> '0') when rst = '1' else
EX_MEM_output(EX_MEM_ALU_OUTPUT_OFFSET+RAM_ADDRESS_SIZE-1 downto EX_MEM_ALU_OUTPUT_OFFSET) when EX_MEM_Use_Memory = '1' and EX_MEM_output(EX_MEM_IMM_OFFSET)= '1' 
else SP_output(RAM_ADDRESS_SIZE-1 downto 0) when EX_MEM_Use_Memory = '1'
else PC_output(RAM_ADDRESS_SIZE-1 downto 0);

RAM_input <= EX_MEM_output(EX_MEM_ALU_OUTPUT_OFFSET+REG_SIZE -1 downto EX_MEM_ALU_OUTPUT_OFFSET) when EX_MEM_Use_Memory = '1' and EX_MEM_output(EX_MEM_IMM_OFFSET)= '0'
else EX_MEM_output(EX_MEM_DST_REG_OFFSET+REG_SIZE-1 downto 
EX_MEM_DST_REG_OFFSET);
-----------------------------------IO registers--------------------------------

IN_PORT: reg generic map (REG_SIZE) 
port map(clk, rst, '1', input_port, IN_PORT_output); 

OUT_PORT: reg generic map (REG_SIZE) 
port map(clk, rst, EX_MEM_output(EX_MEM_IO_OFFSET), OUT_PORT_input, output_port); 
OUT_PORT_en <= EX_MEM_output(EX_MEM_IO_OFFSET) and EX_MEM_output(EX_MEM_WRITE_OFFSET);

OUT_PORT_input <= RAM_input;
-----------------------------------ALU-----------------------------------------
ALU_inst:
alu generic map(REG_SIZE)
port map(ALU_op1, ALU_op2, ALU_sel, C, ALU_output, SetC, ClrC, SetZ, ClrZ,
SetN, ClrN);

ALU_op1 <= ALU_op1_mux1 when ID_EX_output(ID_EX_IMM_OFFSET) = '0'
else ID_EX_output(ID_EX_IMM_VAL_OFFSET+REG_SIZE-1 downto ID_EX_IMM_VAL_OFFSET);

ALU_op1_mux1 <=  
ID_EX_output(ID_EX_DST_REG_OFFSET+REG_SIZE-1 downto ID_EX_DST_REG_OFFSET)           
when Forward_Dst='0'
else EX_MEM_output(EX_MEM_ALU_OUTPUT_OFFSET+REG_SIZE-1 downto EX_MEM_ALU_OUTPUT_OFFSET)  
when Forward_Dst='1' and EX_to_EX_Forwarding_Dst='1'

else RegFileWDst_input 
when Forward_Dst='1' and MEM_to_EX_Forwarding_Dst='1';

ALU_op2 <=  
ID_EX_output(ID_EX_SRC_REG_OFFSET+REG_SIZE-1 downto ID_EX_SRC_REG_OFFSET)
when Forward_Src='0'
else EX_MEM_output(EX_MEM_ALU_OUTPUT_OFFSET+REG_SIZE-1 downto EX_MEM_ALU_OUTPUT_OFFSET)
when Forward_Src='1' and EX_to_EX_Forwarding_Src='1'
else RegFileWDst_input
when Forward_Src='1' and MEM_to_EX_Forwarding_Src='1';  

ALU_sel <= ID_EX_output(ID_EX_ALU_OFFSET+ALU_SEL_SIZE-1 downto ID_EX_ALU_OFFSET);

------------------------------Status register----------------------------------
SR: 
status_register port map(clk, rst, C, SetC, ClrC, Z, SetZ, ClrZ, N, SetN, ClrN);
------------------------------Control signals----------------------------------
ControlUnit:
control_unit generic map(CONTROL_WORD_SIZE, OPCODE_SIZE)
port map(IF_ID_output(IF_ID_OPCODE_OFFSET+OPCODE_SIZE-1 downto
IF_ID_OPCODE_OFFSET), control_unit_output);
---------------------------------Intermediate registers------------------------
IF_ID: 
reg generic map (IF_ID_input'length) 
port map(clk, rst, IF_ID_en, IF_ID_input, IF_ID_output);  

EX_MEM_Use_Memory <= (EX_MEM_output(EX_MEM_READ_OFFSET) or 
EX_MEM_output(EX_MEM_WRITE_OFFSET)) and not EX_MEM_output(EX_MEM_IO_OFFSET);

IF_ID_input <= RAM_output when EX_MEM_Use_Memory = '0' else IF_ID_INSTRUCTION_NOP;

IF_ID_en <= not Load_Use; --TODO: chnage when forwarding implemented

ID_EX: 
reg generic map (ID_EX_input'length) 
port map(clk, rst, ID_EX_en, ID_EX_input, ID_EX_output);  
ID_EX_en <= '1';


ID_EX_input(REG_ADDR+ID_EX_RDST_OFFSET-1 downto ID_EX_RDST_OFFSET) <= 
IF_ID_output(REG_ADDR+IF_ID_DST_OFFSET-1 downto IF_ID_DST_OFFSET);

ID_EX_input(REG_ADDR+ID_EX_RSRC_OFFSET-1 downto ID_EX_RSRC_OFFSET) <= 
IF_ID_output(REG_ADDR+IF_ID_SRC_OFFSET-1 downto IF_ID_SRC_OFFSET);

ID_EX_input(ID_EX_DST_REG_OFFSET+REG_SIZE-1 downto ID_EX_DST_REG_OFFSET) <= 
RegFileDst_output;

ID_EX_input(ID_EX_SRC_REG_OFFSET+REG_SIZE-1 downto ID_EX_SRC_REG_OFFSET) <=
RegFileSrc_output;

ID_EX_input(ID_EX_IMM_VAL_OFFSET+REG_SIZE-1 downto ID_EX_IMM_VAL_OFFSET) <=
IMM_VAL_extended;

IMM_VAL_extended(WORDSIZE-1 downto 0) <= IF_ID_output(WORDSIZE+IF_ID_IMM_OFFSET-1 
downto IF_ID_IMM_OFFSET);
IMM_VAL_extended(REG_SIZE-1 downto WORDSIZE) <= (others => '0');
--IMM_VAL_extended(REG_SIZE-1 downto WORDSIZE) <= (others => '1') when 
--IF_ID_output(WORDSIZE+IF_ID_IMM_OFFSET-1) = '1' else (others => '0');

ID_EX_input(CONTROL_WORD_SIZE+ID_EX_CTRL_SIG_OFFSET-1 downto ID_EX_CTRL_SIG_OFFSET) <=
control_unit_output when Load_Use='0'
else NOP_CONTROL_WORD; --TODO: chnage when forwarding implemented

EX_MEM: 
reg generic map (EX_MEM_input'length) 
port map(clk, rst, EX_MEM_en, EX_MEM_input, EX_MEM_output);  

EX_MEM_en <= '1';

EX_MEM_input(EX_MEM_RDST_OFFSET+REG_ADDR-1 downto EX_MEM_RDST_OFFSET) <=
ID_EX_output(ID_EX_RDST_OFFSET+ REG_ADDR-1 downto ID_EX_RDST_OFFSET);

EX_MEM_input(EX_MEM_DST_REG_OFFSET+REG_SIZE-1 downto EX_MEM_DST_REG_OFFSET) <=
ALU_op1_mux1;
--TODO: Change after making the forward unit.

EX_MEM_input(REG_SIZE+EX_MEM_ALU_OUTPUT_OFFSET-1 downto EX_MEM_ALU_OUTPUT_OFFSET) <=
ALU_output;

EX_MEM_input(EX_MEM_REGWRITE_OFFSET) <= ID_EX_output(ID_EX_REGWRITE_OFFSET);
EX_MEM_input(EX_MEM_WBO_OFFSET)      <= ID_EX_output(ID_EX_WBO_OFFSET);
EX_MEM_input(EX_MEM_IO_OFFSET)       <= ID_EX_output(ID_EX_IO_OFFSET);
EX_MEM_input(EX_MEM_READ_OFFSET)     <= ID_EX_output(ID_EX_READ_OFFSET);
EX_MEM_input(EX_MEM_WRITE_OFFSET)    <= ID_EX_output(ID_EX_WRITE_OFFSET);
EX_MEM_input(EX_MEM_IMM_OFFSET)      <= ID_EX_output(ID_EX_IMM_OFFSET);

MEM_WB: 
reg generic map (MEM_WB_input'length) 
port map(clk, rst, MEM_WB_en, MEM_WB_input, MEM_WB_output);  

MEM_WB_en <= '1';

MEM_WB_input(MEM_WB_RDST_OFFSET+REG_ADDR-1 downto MEM_WB_RDST_OFFSET) <= 
EX_MEM_output(EX_MEM_RDST_OFFSET+REG_ADDR-1 downto EX_MEM_RDST_OFFSET);

MEM_WB_input(MEM_WB_MEM_OUTPUT_OFFSET+REG_SIZE-1 downto MEM_WB_MEM_OUTPUT_OFFSET) <= 
RAM_output 
when EX_MEM_output(EX_MEM_IO_OFFSET) = '0'
else IN_PORT_output;

MEM_WB_input(MEM_WB_ALU_OUTPUT_OFFSET+REG_SIZE-1 downto MEM_WB_ALU_OUTPUT_OFFSET) <=
EX_MEM_output(EX_MEM_ALU_OUTPUT_OFFSET+REG_SIZE-1 downto EX_MEM_ALU_OUTPUT_OFFSET);

MEM_WB_input(MEM_WB_WBO_OFFSET) <= EX_MEM_output(EX_MEM_WBO_OFFSET);
MEM_WB_input(MEM_WB_REGWRITE_OFFSET) <= EX_MEM_output(EX_MEM_REGWRITE_OFFSET);

-- Forwarding Unit

SRC_Equals_EX_Dst        <= '1' when     EX_MEM_output(EX_MEM_RDST_OFFSET+REG_ADDR-1 downto EX_MEM_RDST_OFFSET)=ID_EX_output(ID_EX_RSRC_OFFSET+REG_ADDR-1 downto ID_EX_RSRC_OFFSET)
                                else     '0';
DST_Equals_EX_Dst        <= '1' when     EX_MEM_output(EX_MEM_RDST_OFFSET+REG_ADDR-1 downto EX_MEM_RDST_OFFSET)=ID_EX_output(ID_EX_RDST_OFFSET+REG_ADDR-1 downto ID_EX_RDST_OFFSET)
                                else     '0';
SRC_Equals_MEM_Dst       <= '1' when     MEM_WB_output(MEM_WB_RDST_OFFSET+REG_ADDR-1 downto MEM_WB_RDST_OFFSET)=ID_EX_output(ID_EX_RSRC_OFFSET+REG_ADDR-1 downto ID_EX_RSRC_OFFSET)
                                else     '0';
DST_Equals_MEM_Dst       <= '1' when     MEM_WB_output(MEM_WB_RDST_OFFSET+REG_ADDR-1 downto MEM_WB_RDST_OFFSET)=ID_EX_output(ID_EX_RDST_OFFSET+REG_ADDR-1 downto ID_EX_RDST_OFFSET)
                                else     '0';
EX_to_EX_Forwarding_Src  <=      EX_MEM_output(EX_MEM_REGWRITE_OFFSET)
                             and SRC_Equals_EX_Dst;

EX_to_EX_Forwarding_Dst  <=      EX_MEM_output(EX_MEM_REGWRITE_OFFSET)
                             and DST_Equals_EX_Dst;

MEM_to_EX_Forwarding_Src <=      MEM_WB_output(MEM_WB_REGWRITE_OFFSET)
                             and SRC_Equals_MEM_Dst
                             and not EX_to_EX_Forwarding_Src;

MEM_to_EX_Forwarding_Dst <=      MEM_WB_output(MEM_WB_REGWRITE_OFFSET)
                             and DST_Equals_MEM_Dst
                             and not EX_to_EX_Forwarding_Dst;

Forward_Src              <=     EX_to_EX_Forwarding_Src
                             or MEM_to_EX_Forwarding_Src;

Forward_Dst              <=     EX_to_EX_Forwarding_Dst
                             or MEM_to_EX_Forwarding_Dst;


-- Load Use

Load_Use_Case <= '1' when (ID_EX_output(ID_EX_RDST_OFFSET+REG_ADDR-1 downto ID_EX_RDST_OFFSET)=IF_ID_output(IF_ID_SRC_OFFSET+REG_ADDR-1 downto IF_ID_SRC_OFFSET))
              else '0';
Load_Use      <= ID_EX_output(ID_EX_READ_OFFSET) and Load_Use_Case;

-- SP
SP:
sp_reg generic map (REG_SIZE) 
port map(clk, rst, SP_en, SP_input, SP_output);

SP_en <= '1' when (EX_MEM_output(EX_MEM_IMM_OFFSET)='0') and (EX_MEM_output(EX_MEM_READ_OFFSET) ='1' or EX_MEM_output(EX_MEM_WRITE_OFFSET)='1')
else '0';

SP_Added <= "00000000000000000000000000000010" when EX_MEM_output(EX_MEM_READ_OFFSET) = '1'
else "11111111111111111111111111111110";

SP_adder:
ripple_adder generic map(REG_SIZE)
port map(SP_output, SP_Added, '0', SP_input, SP_carry);

end architecture cpu_0;
