library ieee;                                	
use ieee.std_logic_1164.all;  
use ieee.std_logic_misc.all;  

entity alu is 
generic (WORDSIZE : integer := 16);
port (                 	
    A, B: in std_logic_vector(WORDSIZE-1 downto 0); 
    S: in std_logic_vector(3 downto 0);
    Cin: in std_logic;
    FLAGS_Cin: in std_logic;
    F: out std_logic_vector(WORDSIZE-1 downto 0);
    ALU_FLAGS: out std_logic_vector(WORDSIZE-1 downto 0)
    );            		
end ALU; 

-- Architecture
architecture alu_0 of alu is 

component my_adder is
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
signal Z_flag : std_logic;

begin

  Op2 <= B when S = "0000" or S = "1100" --ADD or ADC
  else not B when S = "0001" or S = "1101" --SUB or SUBC
  else (others => '0');

  Cin_temp <= FLAGS_Cin when S = "1100"
  else FLAGS_Cin when S = "1101"
  else Cin; 
  
  --generate the full adders
  Adders_output_0: my_adder port map(A(0), Op2(0), Cin_temp, F_temp(0), Carry_temp(0));
  adders: for i in 1 to WORDSIZE-1 generate
    Adder_output: my_adder port map(A(i), Op2(i), Carry_temp(i-1), F_temp(i), Carry_temp(i));
  end generate;

  --------------------------------FLAGS-----------------------------------------

  --carry flag
  ALU_FLAGS(0) <= Carry_temp(WORDSIZE-1) when S = "0001" --ADD
  else Carry_temp(WORDSIZE-1) when S = "0010" --SUB
  else B(0) when S = "0110" --SHR
  else B(0) when S = "1000" --RRC
  else B(WORDSIZE-1) when S = "0101" --SHL
  else B(WORDSIZE-1) when S = "0111" --RLC
  else '0';
  
  --zero flag
  Z_flag <= nor_reduce(F_temp);

  --Negative (N) flag
  N_flag <= F_temp(WORDSIZE-1);

  -----------------------------------------------------------------------

  F <= A when S = "0000" --MOV
  else F_temp when S = "0001" --ADD
  else F_temp when S = "0010" --SUB
  else (A and B) when S = "0011" --AND
  else (A or B) when S = "0100" --OR
  else (B(WORDSIZE-2 downto 0) & '0') when S = "0101" --SHL
  else ('0' & B(WORDSIZE-1 downto 1)) when S = "0110" --SHR
  else (B(WORDSIZE-2 downto 0) & B(WORDSIZE-1)) when S = "0111" --RLC
  else (B(0) & B(WORDSIZE-1 downto 1)) when S = "1000" --RRC
  else A when S = "1001" --SETC
  else A when S = "1010" --CLRC
  else not A when S = "1011" --NOT
  else F_temp when S = "1100" --INC
  else F_temp when S = "1101" --DEC
  else F_temp when S = "1110" --NEG
  else (others => '0') when S = "1111" --CLR
  else (others => '0');
  
end architecture alu_0;
