library ieee;
use ieee.std_logic_1164.all;

entity status_register is
  generic (
    REG_SIZE   : integer := 32
  );
  port(
    clk        : in  std_logic;
    rst        : in  std_logic;
    C          : out std_logic;
    SetC, ClrC : in  std_logic;
    Z          : out std_logic;
    SetZ, ClrZ : in  std_logic;
    N          : out std_logic;
    SetN, ClrN : in  std_logic
  );  
end status_register;

architecture status_register_0 of status_register is

--flip flop
component flip_flop is
  port(
    clk    : in std_logic; 
    rst    : in std_logic; 
    preset : in std_logic;
    q      : out std_logic
    );
end component;

signal rstC         : std_logic;
signal rstZ         : std_logic;
signal rstN         : std_logic;

begin

rstC         <= rst or ClrC;
rstZ         <= rst or ClrZ;
rstN         <= rst or ClrN;

C_ff: flip_flop port map(clk, rstC, SetC, C);  
Z_ff: flip_flop port map(clk, rstZ, SetZ, Z);  
N_ff: flip_flop port map(clk, rstN, SetN, N);  

end architecture status_register_0;