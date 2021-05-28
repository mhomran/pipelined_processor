library ieee;                                	
use ieee.std_logic_1164.all;  
use ieee.std_logic_misc.all;  

entity alu is 
generic (WORDSIZE : integer := 16);
port (                 	
    A, B : in std_logic_vector(WORDSIZE-1 downto 0); 
    S : in std_logic_vector(4 downto 0);
    Cin : in std_logic;
    F : inout std_logic_vector(WORDSIZE-1 downto 0);
    SetC, ClrC : out std_logic;
    SetZ, ClrZ : out std_logic;
    SetN, ClrN : out std_logic
    );            		
end ALU; 

-- Architecture
architecture alu_0 of alu is 

component full_adder is
  port (
    a,b,cin : in  std_logic;
    s, cout : out std_logic );
end component;

signal Op1: std_logic_vector(WORDSIZE-1 downto 0);
signal Op2: std_logic_vector(WORDSIZE-1 downto 0);
signal Carry_temp : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal F_temp: std_logic_vector(WORDSIZE-1 downto 0); 
signal Cin_temp : std_logic;
signal N_flag : std_logic;
signal N_flag_Con : std_logic;
signal Z_flag : std_logic;
signal Z_flag_Con : std_logic;
signal C_flag : std_logic;
signal C_flag_Con : std_logic;

constant OP_OP1  : std_logic_vector((S'length)-1 downto 0)  := "00000";
constant OP_ADD  : std_logic_vector((S'length)-1 downto 0)  := "00001";
constant OP_SUB  : std_logic_vector((S'length)-1 downto 0)  := "00010";
constant OP_AND  : std_logic_vector((S'length)-1 downto 0)  := "00011";
constant OP_OR   : std_logic_vector((S'length)-1 downto 0)  := "00100";
constant OP_SHL  : std_logic_vector((S'length)-1 downto 0)  := "00101";
constant OP_SHR  : std_logic_vector((S'length)-1 downto 0)  := "00110";
constant OP_RLC  : std_logic_vector((S'length)-1 downto 0)  := "00111";
constant OP_RRC  : std_logic_vector((S'length)-1 downto 0)  := "01000";
constant OP_SETC : std_logic_vector((S'length)-1 downto 0)  := "01001";
constant OP_CLRC : std_logic_vector((S'length)-1 downto 0)  := "01010";
constant OP_NOT  : std_logic_vector((S'length)-1 downto 0)  := "01011";
constant OP_INC  : std_logic_vector((S'length)-1 downto 0)  := "01100";
constant OP_DEC  : std_logic_vector((S'length)-1 downto 0)  := "01101";
constant OP_NEG  : std_logic_vector((S'length)-1 downto 0)  := "01110";
constant OP_CLR  : std_logic_vector((S'length)-1 downto 0)  := "01111";
constant OP_OP2  : std_logic_vector((S'length)-1 downto 0)  := "10000";

begin

  --operands
  Op1 <= not A when S = OP_NEG   
  else A;

  Op2 <= not B when S = OP_SUB 
  else (others => '1') when S = OP_DEC 
  else B when S = OP_ADD or S = OP_AND or S = OP_OR 
  else (others => '0');

  --Cin
  Cin_temp <= '1' when S = OP_INC or S = OP_NEG or S = OP_SUB
  else '0'; 
  --generate the full adders
  Adders_output_0: full_adder port map(Op1(0), Op2(0), Cin_temp, F_temp(0), Carry_temp(0));
  adders: for i in 1 to WORDSIZE-1 generate
    Adder_output: full_adder port map(Op1(i), Op2(i), Carry_temp(i-1), F_temp(i), Carry_temp(i));
  end generate;

  --------------------------------FLAGS-----------------------------------------

  --carry flag
  C_flag <= Carry_temp(WORDSIZE-1) when S = OP_ADD
  else Carry_temp(WORDSIZE-1) when S = OP_SUB
  else Op1(0) when S = OP_SHR
  else Op1(0) when S = OP_RRC
  else Op1(WORDSIZE-1) when S = OP_SHL
  else Op1(WORDSIZE-1) when S = OP_RLC
  else '1' when S = OP_SETC 
  else '0';

  C_flag_con <= '1' 
  when S = OP_ADD or S = OP_SUB or S = OP_SETC or S = OP_CLRC or S = OP_SHL or
  S = OP_SHR or S = OP_RLC or S = OP_RRC
  else '0';

  SetC <= C_flag_con and C_flag;
  ClrC <= C_flag_con and not C_flag; 
  
  --zero flag
  Z_flag <= '1' when S = OP_CLR else nor_reduce(F);

  Z_flag_con <= '1' when S = OP_CLR or S = OP_NOT or S = OP_INC or 
  S = OP_DEC or S = OP_NEG or S = OP_ADD or S = OP_SUB or S = OP_AND or
  S = OP_OR else '0';

  SetZ <= Z_flag_con and Z_flag;
  ClrZ <= Z_flag_con and not Z_flag; 

  --Negative (N) flag
  N_flag <= F(WORDSIZE-1);

  N_flag_con <= '1' when S = OP_NOT or S = OP_INC or S = OP_DEC or S = OP_NEG or
  S = OP_ADD or S = OP_SUB or S = OP_AND or S = OP_OR
  else '0';

  SetN <= N_flag_con and N_flag;
  ClrN <= N_flag_con and not N_flag; 
  -----------------------------------------------------------------------------

  F <= A when S = OP_OP1 
  else F_temp when S = OP_ADD 
  else F_temp when S = OP_SUB 
  else (A and B) when S = OP_AND 
  else (A or B) when S = OP_OR 
  else (A(WORDSIZE-2 downto 0) & '0') when S = OP_SHL 
  else ('0' & A(WORDSIZE-1 downto 1)) when S = OP_SHR 
  else (A(WORDSIZE-2 downto 0) & Cin) when S = OP_RLC 
  else (Cin & A(WORDSIZE-1 downto 1)) when S = OP_RRC 
  else not A when S = OP_NOT 
  else F_temp when S = OP_INC 
  else F_temp when S = OP_DEC 
  else F_temp when S = OP_NEG 
  else (others => '0') when S = OP_CLR 
  else B when S = OP_OP2 
  else (others => '0');
  
end architecture alu_0;
