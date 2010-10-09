library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--  A testbench has no ports.
entity cpu_tb is
  end cpu_tb;

architecture behav of cpu_tb is
  --  Declaration of the component that will be instantiated.
  component cpu
   Port(clk            : IN std_logic;
		Rinsel         : IN std_logic_vector(2 DOWNTO 0); -- Which register to write
		Routsel        : IN std_logic_vector(2 DOWNTO 0); -- Which register to read
		read, write    : IN std_logic; -- Flags for read or write control
		Rin            : IN std_logic_vector(7 DOWNTO 0); -- Input signals
		Rout           : OUT std_logic_vector(7 DOWNTO 0)); -- Output signals
  end component;
  --  Specifies which entity is bound with the component.
  for cpu_0: cpu use entity work.cpu;
	signal clk, read, write	: std_logic;
    signal Rinsel, Routsel  : std_logic_vector(2 DOWNTO 0);
    signal Rin              : std_logic_vector(7 DOWNTO 0);
    signal Rout             : std_logic_vector(7 DOWNTO 0));
  begin
    --  Component instantiation.
    cpu_0: cpu port map (clk => clk, read => read, write => write, Rinsel => Routsel, Routsel => Routsel, Rin => Rin, Rout => Rout);

    --  This process does the real job.
    process
    type pattern_type is record
	  clk, read, write  : std_logic;
      Rinsel, Routsel   : std_logic_vector(2 DOWNTO 0);
      Rin               : std_logic_vector(7 DOWNTO 0);
      Rout              : std_logic_vector(7 DOWNTO 0));
    end record;
  --  The patterns to apply.
  type pattern_array is array (natural range <>) of pattern_type;
  constant patterns : pattern_array :=
  -- clk   read   write  Rinsel   Routsel  Rin         Rout
  (('1',   '1',   '0',   "000",   "001",   "00000000", "00000000")
  -- TODO: Need to make clock oscillate
  -- TODO: reg0 to reg7
  );
begin
  --  Check each pattern.
  for i in patterns'range loop
    --  Set the inputs.
    clk <= patterns(i).clk;
    read <= patterns(i).read;
    write <= patterns(i).write;
    Rinsel <= patterns(i).Rinsel;
    Routsel <= patterns(i).Routsel;
	Rin <= patterns(i).Rout;
    --  Wait for the results.
    wait for 1 ns;
    --  Check the outputs.
    assert Rout = patterns(i).Rout
    report "bad output register value" severity error;
  end loop;
  assert false report "end of test" severity note;
  --  Wait forever; this will finish the simulation.
  wait;
end process;
end behav;

