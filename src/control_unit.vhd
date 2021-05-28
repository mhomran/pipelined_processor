library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity control_unit is
  generic (
    CONTROL_WORD_SIZE : integer := 10;
    OPCODE_SIZE : integer := 5
  );
  port(
      opcode : in std_logic_vector(OPCODE_SIZE-1 downto 0);
      control_word : out std_logic_vector(CONTROL_WORD_SIZE-1 downto 0)
    );  
end control_unit;

architecture control_unit_0 of control_unit is
  --OP codes
  constant OC_NOP  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "00000";
  constant OC_ADD  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "00001";
  constant OC_SUB  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "00010";
  constant OC_AND  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "00011";
  constant OC_OR   : std_logic_vector(OPCODE_SIZE-1 downto 0) := "00100";
  constant OC_IADD : std_logic_vector(OPCODE_SIZE-1 downto 0) := "00101";
  constant OC_SHL  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "00110";
  constant OC_SHR  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "00111";
  constant OC_RLC  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "01000";
  constant OC_RRC  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "01001";
  constant OC_MOV  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "01010";
  constant OC_SETC : std_logic_vector(OPCODE_SIZE-1 downto 0) := "01011";
  constant OC_CLRC : std_logic_vector(OPCODE_SIZE-1 downto 0) := "01100";
  constant OC_CLR  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "01101";
  constant OC_NOT  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "01110";
  constant OC_INC  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "01111";
  constant OC_DEC  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "10000";
  constant OC_NEG  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "10001";
  constant OC_OUT  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "10010";
  constant OC_IN   : std_logic_vector(OPCODE_SIZE-1 downto 0) := "10011";
  constant OC_LDM  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "10100";
  constant OC_LDD  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "10101";
  constant OC_STD  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "10110";

  --Control words
  constant CW_NOP  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0000000000";
  constant CW_ADD  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0000010001";
  constant CW_SUB  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0000100001";
  constant CW_AND  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0000110001";
  constant CW_OR   : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0001000001";
  constant CW_IADD : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0000011001";
  constant CW_SHL  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0001011001";
  constant CW_SHR  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0001101001";
  constant CW_RLC  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0001110001";
  constant CW_RRC  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0010000001";
  constant CW_MOV  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0000000001";
  constant CW_SETC : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0010010000";
  constant CW_CLRC : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0010100000";
  constant CW_CLR  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0011110001";
  constant CW_NOT  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0010110001";
  constant CW_INC  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0011000001";
  constant CW_DEC  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0011010001";
  constant CW_NEG  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0011100001";
  constant CW_OUT  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0000000100";
  constant CW_IN   : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0100000111";
  constant CW_LDM  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0000001001";
  constant CW_LDD  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "0100010011";
  constant CW_STD  : std_logic_vector(CONTROL_WORD_SIZE-1 downto 0) :=  "1000011000";

 begin
  control_word <= 
  CW_MOV  when opcode = OC_MOV  else
  CW_ADD  when opcode = OC_ADD  else
  CW_SUB  when opcode = OC_SUB  else
  CW_AND  when opcode = OC_AND  else
  CW_OR   when opcode = OC_OR   else
  CW_IADD when opcode = OC_IADD else
  CW_SHL  when opcode = OC_SHL  else
  CW_SHR  when opcode = OC_SHR  else
  CW_RLC  when opcode = OC_RLC  else
  CW_RRC  when opcode = OC_RRC  else
  CW_NOP  when opcode = OC_NOP  else
  CW_SETC when opcode = OC_SETC else
  CW_CLRC when opcode = OC_CLRC else
  CW_CLR  when opcode = OC_CLR  else
  CW_NOT  when opcode = OC_NOT  else
  CW_INC  when opcode = OC_INC  else
  CW_DEC  when opcode = OC_DEC  else
  CW_NEG  when opcode = OC_NEG  else
  CW_OUT  when opcode = OC_OUT  else
  CW_IN   when opcode = OC_IN   else
  CW_LDM  when opcode = OC_LDM  else
  CW_LDD  when opcode = OC_LDD  else
  CW_STD  when opcode = OC_STD  else
  (others => '0');
end architecture control_unit_0;