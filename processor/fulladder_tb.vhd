-- Authors:
--      Henry Jenkins, Joel Koh

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--  A testbench has no ports.
entity fulladder8_tb is
  end fulladder8_tb;

architecture behav of fulladder8_tb is
  --  Declaration of the component that will be instantiated.
  component fulladder8
  Port (A    : in   STD_LOGIC_VECTOR( 7 downto 0);
        B    : in   STD_LOGIC_VECTOR( 7 downto 0);
        Cin  : in   STD_LOGIC;
        Sum  : out  STD_LOGIC_VECTOR( 7 downto 0);
        Cout : out  STD_LOGIC
        );
  end component;
  --  Specifies which entity is bound with the component.
  for fulladder8_0: fulladder8 use entity work.fulladder8;
    signal A,B,Sum    : STD_LOGIC_VECTOR (7 downto 0);
    signal Cin,Cout   : STD_LOGIC;
  begin
    --  Component instantiation.
    fulladder8_0: fulladder8 port map (A => A, B => B, Cin => Cin, Sum => Sum, Cout => Cout);

    --  This process does the real job.
    process
    type pattern_type is record
      A    :  STD_LOGIC_VECTOR( 7 downto 0);
      B    :  STD_LOGIC_VECTOR( 7 downto 0);
      Cin  :  STD_LOGIC;
      Sum  :  STD_LOGIC_VECTOR( 7 downto 0);
      Cout :  STD_LOGIC;
    end record;
  --  The patterns to apply.
  type pattern_array is array (natural range <>) of pattern_type;
  constant patterns : pattern_array :=
  -- A           B          Cin   Sum     Cout
  (("00000000", "00000000", '0', "00000000", '0'), --AND tests - 1ns
   ("11111111", "11111111", '1', "11111111", '1'), --AND tests
   ("00000000", "00000000", '1', "00000001", '0'), --AND tests
   ("00000000", "11111111", '0', "11111111", '0'), --AND tests
   ("11111111", "00000000", '0', "11111111", '0'), --AND tests
   ("11111111", "00000000", '1', "00000000", '1'), --AND tests
   ("10101010", "01010101", '0', "11111111", '0'), --AND tests
   ("10101010", "01010101", '1', "00000000", '1'), --AND tests
   ("11111111", "11111111", '0', "11111110", '1')  --XOR tests
  );
begin
  --  Check each pattern.
  for i in patterns'range loop
    --  Set the inputs.
    A   <= patterns(i).A;
    B   <= patterns(i).B;
    Cin <= patterns(i).Cin;
    --  Wait for the results.
    wait for 1 ns;
    --  Check the outputs.
    assert Sum = patterns(i).Sum
    report "The sum check failed" severity error;
    assert Cout = patterns(i).Cout
    report "The carry out is wrong" severity error;
  end loop;
  assert false report "end of test" severity note;
  --  Wait forever; this will finish the simulation.
  wait;
end process;
end behav;

