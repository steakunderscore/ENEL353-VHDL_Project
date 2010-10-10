library work;
use work.cpu;
use work.mmu;
use work.io;

entity everything is
  port (
    clk : in std_logic;
	 tx  : out std_logic;
	 rx  : in std_logic
  )
end everything;

architecture everything_arch of everything is
  signal clk      : std_logic;
  
  begin
    c : cpu port map(
        clk => clk
      );
    m : mmu port map(
        clk => clk
      );
    i : io  port map(
        clk => clk
      );
end architecture everything_arch;