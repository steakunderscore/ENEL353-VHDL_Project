------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;

entity spr_TB is      -- entity declaration
  end spr_TB;

architecture TB of spr_TB is

  component sr
  Port (clk      : in   STD_LOGIC;
        enable   : in   STD_LOGIC;                       -- Enable write
        Ri       : in   STD_LOGIC_VECTOR (15 downto 0);  -- The input to the SPR
        Ro       : out  STD_LOGIC_VECTOR (15 downto 0)); -- The output from SPR
  end component;

  signal sr_enable : std_logic;
  signal sr_Ri     : std_logic_vector(15 downto 0);
  signal sr_Ro     : std_logic_vector(15 downto 0);

  component pc
  Port (clk      : in   STD_LOGIC;
        enable   : in   STD_LOGIC;                       -- Enable write
        Ri       : in   STD_LOGIC_VECTOR (15 downto 0);  -- The input to the SPR
        Ro       : out  STD_LOGIC_VECTOR (15 downto 0)); -- The output from SPR
  end component;

  signal pc_enable : std_logic;
  signal pc_Ri     : std_logic_vector(15 downto 0);
  signal pc_Ro     : std_logic_vector(15 downto 0);

  signal T_clk  : std_logic;

begin

  U_sr: sr port map (clk => T_clk, enable => sr_enable, Ri => sr_Ri, Ro => sr_Ro);
  U_pc: pc port map (clk => T_clk, enable => pc_enable, Ri => pc_Ri, Ro => pc_Ro);

    -- concurrent process to offer the clk signal
  process
  begin
    T_clk <= '0';
    wait for 5 ns;
    T_clk <= '1';
    wait for 5 ns;
  end process;

  process

    variable err_cnt: integer :=0;

  begin

    -- Write
    sr_enable <= '1';
    sr_Ri     <= "0100011001011001";
    pc_enable <= '1';
    pc_Ri     <= "0101011010110100";
    wait for 20 ns;

    -- Read
    assert (sr_Ro="0100011001011001") report "Read sr #1 failed" severity error;
    assert (pc_Ro="0101011010110100") report "Read pc #1 failed" severity error;

    -- Change Ri
    sr_Ri <= "1001100101110100";
    pc_Ri <= "0001010001110000";
    wait for 20 ns;
    assert (sr_Ro = "1001100101110100") report "Read sr #2 failed" severity error;
    assert (pc_Ro = "0001010001110000") report "Read pc #2 failed" severity error;

    -- Disable sr, pc still enabled
    sr_enable <= '0';
    sr_Ri <= "0101010101010101";
    pc_Ri <= "1010101010101010";
    wait for 20 ns;
    assert (sr_Ro = "1001100101110100") report "Wrote to sr while disabled" severity error;
    assert (pc_Ro = "1010101010101010") report "Read pc #3 failed" severity error;

    -- Enable sr
    sr_enable <= '1';
    wait for 20 ns;
    assert (sr_Ro = "0101010101010101") report "Read sr #3 failed" severity error;

    -- Disable pc, sr still enabled
    pc_enable <= '0';
    sr_Ri <= "0000000011111111";
    pc_Ri <= "1111111100000000";
    wait for 20 ns;
    assert (sr_Ro = "0000000011111111") report "Read sr #4 failed" severity error;
    assert (pc_Ro = "1010101010101010") report "Wrote to pc while disabled" severity error;

    -- Enable pc
    pc_enable <= '1';
    wait for 20 ns;
    assert (pc_Ro = "1111111100000000") report "Read pc #4 failed" severity error;


    assert false report "End of test" severity note;
    wait; -- wait forever to end the test

  end process;

end TB;

------------------------------------------------------------------
configuration CFG_TB of spr_TB is
  for TB
  end for;
end CFG_TB;
