library ieee;
use ieee.std_logic_1164.all;

entity flip_flop is
  port(
    clk    : in std_logic; 
    rst    : in std_logic; 
    preset : in std_logic;
    q      : out std_logic
    );
end flip_flop;

architecture flip_flop_1 of flip_flop is
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        q <= '0';
      elsif preset = '1' then     
        q <= '1';
      end if;
    end if;
  end process;  
end flip_flop_1;


