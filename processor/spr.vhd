-- Authors:
--      Henry Jenkins, Joel Koh

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.reg16;

entity sr is
  Port (clk      : in  STD_LOGIC;
        enable   : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        Ri       : in  STD_LOGIC_VECTOR (15 downto 0);  -- The input to the SR
        Ro       : out STD_LOGIC_VECTOR (15 downto 0)); -- The output from SR
end sr;

architecture sr_arch of sr is
  component reg16 IS
  port(I      : in  std_logic_vector(15 downto 0);
       clock  : in  std_logic;
       enable : in  std_logic;
       reset  : in  STD_LOGIC;
       Q      : out std_logic_vector(15 downto 0)
     );
  end component;
BEGIN
  reg_sr : reg16 port map(Ri, clk, enable, reset, Ro);
end sr_arch;

----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pc is
  Port (clk      : in  STD_LOGIC;
        enable   : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        Ri       : in  STD_LOGIC_VECTOR (15 downto 0);  -- The input to the SR
        Ro       : out STD_LOGIC_VECTOR (15 downto 0)); -- The output from SR
end pc;


architecture pc_arch of pc is
  component reg16 IS
  port(I      : in  std_logic_vector(15 downto 0);
       clock  : in  std_logic;
       enable : in  std_logic;
       reset  : in  STD_LOGIC;
       Q      : out std_logic_vector(15 downto 0)
     );
  end component;
BEGIN
  reg_pc : reg16 port map(Ri, clk, enable, reset, Ro);
end pc_arch;

