library ieee;
use ieee.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ram is
  generic(
    WORDSIZE : integer := 16;
    ADDRESS_SIZE : integer := 6
  );
  port(
    clk : in std_logic;
    we  : in std_logic;
    address : in  std_logic_vector(ADDRESS_SIZE-1 downto 0);
    datain  : in  std_logic_vector(WORDSIZE*2-1 downto 0);
    dataout : out std_logic_vector(WORDSIZE*2-1 downto 0)
    );
end entity ram;

architecture ram_0 OF ram is

  type ram_type is array(0 TO 2**ADDRESS_SIZE-1) OF std_logic_vector(WORDSIZE-1 downto 0);
  signal ram : ram_type;

  begin
    process(clk) is
      begin
        if rising_edge(clk) THEN  
          if we = '1' THEN
            --big endian
            ram(to_integer(unsigned(address))) <= datain(WORDSIZE*2-1 downto WORDSIZE);
            ram(to_integer(unsigned(address))+1) <= datain(WORDSIZE-1 downto 0);
          end if;
        end if;
    end process;
    dataout <= ram(to_integer(unsigned(address))) & ram(to_integer(unsigned(address))+1);
end ram_0;
