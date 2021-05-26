library ieee;
use ieee.std_logic_1164.all;

entity register_file is
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
end register_file;

architecture register_file_0 of register_file is

----------------------------------declaration----------------------------------
--register 
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

--decoder
component decAxB is
  generic (INPUT_SIZE: integer := 2);
  port(
      en : in std_logic; 
      A  : in std_logic_vector(INPUT_SIZE-1 downto 0);
      Y  : out std_logic_vector(2**INPUT_SIZE-1 downto 0)
   );
end component;
----------------------------------Signals--------------------------------------

signal inverted_clk : std_logic;
type R_out is array (REG_NUM-1 downto 0) of std_logic_vector(REG_SIZE-1 DOWNTO 0);
signal R_output : R_out;
signal R_input_en : std_logic_vector(REG_NUM-1 DOWNTO 0);
signal R_output_src_en : std_logic_vector(REG_NUM-1 DOWNTO 0);
signal R_output_dst_en : std_logic_vector(REG_NUM-1 DOWNTO 0);

begin
  inverted_clk <= not clk;
  
  R: for i in 0 to REG_NUM-1 generate
    R_reg: reg generic map (REG_SIZE) 
    port map(inverted_clk, rst, R_input_en(i), data, R_output(i));  

    src_op <= R_output(i) when R_output_src_en(i) = '1' else (others => 'Z');
    dst_op <= R_output(i) when R_output_dst_en(i) = '1' else (others => 'Z');
  end generate;
  
  src_out_dec_inst: decAxB generic map (REG_ADDR) 
  port map('1', src, R_output_src_en);

  dst_out_dec_inst: decAxB generic map (REG_ADDR) 
  port map('1', dst, R_output_dst_en);
  
  dst_in_dec_inst: decAxB generic map (REG_ADDR) 
  port map(RegWrite, wr_reg, R_input_en);

end architecture register_file_0; -- register_file_0