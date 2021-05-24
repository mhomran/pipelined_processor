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
    clk : in std_logic;
    rst : in std_logic
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
		WORDSIZE : integer := 16;
		ADDRESS_SIZE : integer := 16
	);
	port (
		clk     : in  std_logic;
		we      : in  std_logic;
		address : in  std_logic_vector(ADDRESS_SIZE-1 downto 0);
		datain  : in  std_logic_vector(WORDSIZE-1 downto 0);
		dataout : out std_logic_vector(WORDSIZE-1 downto 0));
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

constant CONTROL_WORD_SIZE : integer := 10;
constant MemWrite_offset   : integer := CONTROL_WORD_SIZE - 1;
constant MemRead_offset    : integer := CONTROL_WORD_SIZE - 2;
constant ALU_offset        : integer := CONTROL_WORD_SIZE - 3;
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

---------------------------------signals---------------------------------------
--constants
constant INSTRUCTION_SIZE   : integer := WORDSIZE*2;
constant IMMEDIATE_VAL_SIZE : integer := WORDSIZE;

--Intermediate registers
signal IF_ID_input  : std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal IF_ID_output : std_logic_vector(IF_ID_input'length downto 0);
signal IF_ID_en     : std_logic;

signal ID_EX_input  : std_logic_vector(
((CONTROL_WORD_SIZE + IMMEDIATE_VAL_SIZE + 2*REG_SIZE + REG_ADDR)-1) downto 0);
signal ID_EX_output : std_logic_vector(ID_EX_input'length downto 0);
signal ID_EX_en     : std_logic;

begin
---------------------------------Intermediate registers------------------------
IF_ID: 
reg generic map (IF_ID_input'length) 
port map(clk, rst, IF_ID_en, IF_ID_input, IF_ID_output);  

ID_EX: 
reg generic map (ID_EX_input'length) 
port map(clk, rst, ID_EX_en, ID_EX_input, ID_EX_output);  

end architecture cpu_0;

