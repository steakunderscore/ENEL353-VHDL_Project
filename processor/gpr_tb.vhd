-- Authors:
--      Henry Jenkins, Joel Koh

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--  A testbench has no ports.
entity gpr_tb is
  end gpr_tb;

architecture behav of gpr_tb is
  --  Declaration of the component that will be instantiated.
  component gpr
  Port(clk                  : IN std_logic;                     -- Clock
       enable               : IN std_logic;                     -- Enable input (output is always enabled)
       SelRx, SelRy, SelRi  : IN std_logic_vector(2 DOWNTO 0);  -- Selecti which registers to use
       Ri                   : IN std_logic_vector(7 DOWNTO 0);  -- Input
       Rx, Ry               : OUT std_logic_vector(7 DOWNTO 0)); -- Outputs
  end component;
  --  Specifies which entity is bound with the component.
  for gpr_0: gpr use entity work.gpr;
  signal clk, enable          : std_logic;
  signal SelRx, SelRy, SelRi  : std_logic_vector(2 DOWNTO 0);
  signal Ri, Rx, Ry           : std_logic_vector(7 DOWNTO 0);
begin
  --  Component instantiation.
  gpr_0: gpr port map (clk => clk, enable => enable, SelRx => SelRx, SelRy => SelRy, SelRi => SelRi, Ri => Ri, Rx => Rx, Ry => Ry);

  -- Does the clock signal
  process
  begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process;

  --  This process does the real job.
  process
  begin

    -- Write to R0
    SelRi <= "000";
    Ri <= "00010100";
    enable <= '1';
    wait for 20 ns;

    -- Read R0 from Rx
    SelRx <= "000";
    wait for 20 ns;
    assert (Rx = "00010100") report "Read from Rx failed #1" severity error;

    -- Read R0 from Ry
    SelRy <= "000";
    wait for 20 ns;
    assert (Ry = "00010100") report "Read from Ry failed #1" severity error;

    -- Disable write
    enable <= '0';
    wait for 20 ns;

    -- Change Ri (should not write as it is disabled)
    Ri <= "00101010";
    wait for 20 ns;
    assert (Rx = "00010100") report "Wrote to register while disabled #1" severity error;
    assert (Ry = "00010100") report "Wrote to register while disabled #2" severity error;
    
    -- Enable write
    enable <= '1';
    wait for 20 ns;
    assert (Rx = "00101010") report "Read from Rx failed #2" severity error;
    assert (Ry = "00101010") report "Read from Ry failed #2" severity error;

    -- Write to R2
    SelRi <= "010";
    Ri <= "01010001";
    wait for 20 ns;

    -- Read R2 from Rx
    SelRx <= "010";
    wait for 20 ns;
    assert (Rx = "01010001") report "Read from Rx failed #3" severity error;

    -- Read R2 from Ry
    SelRy <= "010";
    wait for 20 ns;
    assert (Ry = "01010001") report "Read from Ry failed #3" severity error;

    -- Read R0 from Rx again (should not have changed from previous results)
    SelRx <= "000";
    wait for 20 ns;
    assert (Rx = "00101010") report "Read from Rx failed #4" severity error;
    
    -- Read R0 from Ry again (should not have changed from previous results)
    SelRy <= "000";
    wait for 20 ns;
    assert (Ry = "00101010") report "Read from Ry failed #4" severity error;

    -- Wait for a long time
    wait for 1 ms;
    assert (Rx = "00101010") report "Read from Rx failed #5" severity error;
    assert (Ry = "00101010") report "Read from Ry failed #5" severity error;
    
    -- Read R2 after a long time
    SelRx <= "010";
    SelRy <= "010";
    wait for 1 ms;
    assert (Rx = "01010001") report "Read from Rx failed #6" severity error;
    assert (Ry = "01010001") report "Read from Ry failed #6" severity error;


    assert false report "End of test" severity note;
    wait; -- wait forever to end the test
    
  end process;
end behav;

