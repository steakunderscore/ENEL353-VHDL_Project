------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;

entity spr_TB is      -- entity declaration
  end spr_TB;

------------------------------------------------------------------

architecture TB of spr_TB is

  component spr
  Port (clk      : in   STD_LOGIC;
        enable   : in   STD_LOGIC;
        read     : in   STD_LOGIC;                       -- (not write)
        SelR     : in   STD_LOGIC_VECTOR (1 downto 0);   -- PC(0) SR(1) IR(2)
        Ri       : in   STD_LOGIC_VECTOR (15 downto 0);  -- The input to the SPR
        Ro       : out  STD_LOGIC_VECTOR (15 downto 0)); -- The output from SPR
  end component;

  signal T_clk    : std_logic;
  signal T_enable : std_logic;
  signal T_read   : std_logic;
  signal T_SelR   : std_logic_vector(1 downto 0);
  signal T_Ri     : std_logic_vector(15 downto 0);
  signal T_Ro     : std_logic_vector(15 downto 0);

begin

  U_spr: spr port map (T_clk, T_enable, T_read, T_SelR, T_Ri, T_Ro);

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

    T_enable <= '1';
    T_read   <= '0';
    T_SelR   <= "00";
    T_Ri     <= "0100011001011001";

    -- case 1
    wait for 20 ns;
    T_read <= '1';
    T_SelR <= "00";
    wait for 20 ns;
    assert (T_Ro="0100011001011001") report "Test1 Failed!" severity error;
    if (T_Ro/=T_Ri) then
      err_cnt := err_cnt+1;
    end if;

     -- summary of all the tests
    if (err_cnt=0) then
      assert false
      report "Testbench of register completely successfully!"
      severity note;
    else
      assert true
      report "Something wrong, check again pls!"
      severity error;
    end if;

    wait;

  end process;

end TB;

------------------------------------------------------------------
configuration CFG_TB of spr_TB is
  for TB
  end for;
end CFG_TB;
------------------------------------------------------------------

