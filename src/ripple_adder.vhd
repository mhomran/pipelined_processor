library ieee;
use ieee.std_logic_1164.all;

entity ripple_adder is
  generic (
    SIZE : integer := 32
    );
	port (
    op1, op2 : in std_logic_vector(SIZE-1 downto 0);
    cin : in std_logic;
    result : out  std_logic_vector(SIZE-1 downto 0);
    cout : out std_logic
    );
end ripple_adder;

-- Architecture
architecture ripple_adder_0 of ripple_adder is 

-----------------------------------Declarations--------------------------------
component full_adder is
  port (
    a,b,cin : in  std_logic;
    s, cout : out std_logic );
end component;

-----------------------------------Signals-------------------------------------
signal carry_temp : std_logic_vector(SIZE-1 DOWNTO 0);

begin

  --generate the full adders
  Adders_output_0: full_adder port map(op1(0), op2(0), cin, result(0), carry_temp(0));
  adders: for i in 1 to SIZE-1 generate
    Adder_output: full_adder port map(op1(i), op2(i), carry_temp(i-1), result(i), carry_temp(i));
  end generate;
  cout <= carry_temp(SIZE-1);

end ripple_adder_0;