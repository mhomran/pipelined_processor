library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decAxB is
  generic (INPUT_SIZE: integer := 2);
  port(
      en : in std_logic; 
      A  : in std_logic_vector(INPUT_SIZE-1 downto 0);
      Y  : out std_logic_vector(2**INPUT_SIZE-1 downto 0)
   );
end decAxB;

architecture decAxB_1 of decAxB is
  signal Y_temp : std_logic_vector(2**INPUT_SIZE-1 downto 0);
begin
  Y <= (others => '0') when en = '0'
  else Y_temp;

  process(A)
    begin
      Y_temp <= (others => '0'); 
      Y_temp(to_integer(unsigned(A))) <= '1';
    end process;

end decAxB_1;

