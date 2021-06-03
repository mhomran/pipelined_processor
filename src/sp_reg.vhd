library ieee;
use ieee.std_logic_1164.all;

entity sp_reg is
generic (WORDSIZE : integer := 32);
      port(
        clk : in std_logic; 
        rst : in std_logic; 
        en : in std_logic;
        d : in std_logic_vector(WORDSIZE-1 downto 0);
        q : out std_logic_vector(WORDSIZE-1 downto 0)
        );
end sp_reg;

architecture sp_reg_1 of sp_reg is
begin
  process(clk)
  begin
    if falling_edge(clk) then
      if rst = '1' then
        q <= "00000000000000000000000000001000";
      elsif en = '1' then     
        q <= d;
      end if;
    end if;
  end process;  
end sp_reg_1;

--11111111111111111111111111111110

