-- Authors:
--      Henry Jenkins, Joel Koh

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--  A testbench has no ports.
entity alu_tb is
  end alu_tb;

architecture behav of alu_tb is
  --  Declaration of the component that will be instantiated.
  component alu
   Port (f   : in   STD_LOGIC_VECTOR (3 downto 0);  -- Function (opcode)
         rx  : in   STD_LOGIC_VECTOR (7 downto 0);  -- Input x (Rx)
         ry  : in   STD_LOGIC_VECTOR (7 downto 0);  -- Input y (Ry)
         ro  : out  STD_LOGIC_VECTOR (7 downto 0);  -- Output Normaly (Ry)
         Cin : in   STD_LOGIC;                      -- Carry in
         sr  : out  STD_LOGIC_VECTOR (15 downto 0)); -- Status register out Z(0), C(1), N(2)
  end component;
  --  Specifies which entity is bound with the component.
  for alu_0: alu use entity work.alu;
    signal f          : STD_LOGIC_VECTOR (3 downto 0);
    signal rx, ry, ro : STD_LOGIC_VECTOR (7 downto 0);
    signal Cin        : STD_LOGIC;
    signal sr         : STD_LOGIC_VECTOR (15 downto 0);
  begin
    --  Component instantiation.
    alu_0: alu port map (f => f, rx => rx, ry => ry, ro => ro, Cin => Cin, sr => sr);

    --  This process does the real job.
    process
    type pattern_type is record
      f          : STD_LOGIC_VECTOR (3 downto 0);
      rx, ry     : STD_LOGIC_VECTOR (7 downto 0);
      ro         : STD_LOGIC_VECTOR (7 downto 0);
      Cin        : STD_LOGIC;
      sr         : STD_LOGIC_VECTOR (15 downto 0);
    end record;
  --  The patterns to apply.
  type pattern_array is array (natural range <>) of pattern_type;
  constant patterns : pattern_array :=
  -- f       rx          ry          ro         Cin   sr
  (("0001", "00000000", "00000000", "00000000", '0', "0000000000000001"), --AND tests - 1ns
   ("0001", "00000001", "00000001", "00000001", '0', "0000000000000000"), --AND tests
   ("0001", "00000000", "00000001", "00000000", '0', "0000000000000001"), --AND tests
   ("0001", "10101010", "10101010", "10101010", '0', "0000000000000100"), --AND tests
   ("0001", "01010101", "01010101", "01010101", '0', "0000000000000000"), --AND tests - 5ns
   ("0001", "11111111", "00000000", "00000000", '0', "0000000000000001"), --AND tests
   ("0001", "11111111", "11111111", "11111111", '0', "0000000000000100"), --AND tests
   ("0001", "00000000", "01010101", "00000000", '0', "0000000000000001"), --AND tests
   ("0001", "00000000", "10101010", "00000000", '0', "0000000000000001"), --AND tests
   ("0001", "11111111", "01010101", "01010101", '0', "0000000000000000"), --AND tests - 10 ns
   ("0001", "11111111", "10101010", "10101010", '0', "0000000000000100"), --AND tests
   ("0001", "10000011", "10110010", "10000010", '0', "0000000000000100"), --AND tests
   ("0001", "00000011", "00110010", "00000010", '0', "0000000000000000"), --AND tests

   ("0011", "00000000", "00000000", "00000000", '0', "0000000000000001"), --OR tests - 14 ns
   ("0011", "00000001", "00000001", "00000001", '0', "0000000000000000"), --OR tests
   ("0011", "00000000", "00000001", "00000001", '0', "0000000000000000"), --OR tests
   ("0011", "10101010", "10101010", "10101010", '0', "0000000000000100"), --OR tests
   ("0011", "01010101", "01010101", "01010101", '0', "0000000000000000"), --OR tests
   ("0011", "11111111", "00000000", "11111111", '0', "0000000000000100"), --OR tests
   ("0011", "11111111", "11111111", "11111111", '0', "0000000000000100"), --OR tests - 20 ns
   ("0011", "00000000", "01010101", "01010101", '0', "0000000000000000"), --OR tests
   ("0011", "00000000", "10101010", "10101010", '0', "0000000000000100"), --OR tests
   ("0011", "11111111", "01010101", "11111111", '0', "0000000000000100"), --OR tests
   ("0011", "11111111", "10101010", "11111111", '0', "0000000000000100"), --OR tests
   ("0011", "10000011", "10110010", "10110011", '0', "0000000000000100"), --OR tests - 25 ns
   ("0011", "00000011", "00110010", "00110011", '0', "0000000000000000"), --OR tests

   ("0101", "00000000", "00000000", "11111111", '0', "0000000000000100"), --NOT tests - ry should not matter
   ("0101", "00000001", "00000001", "11111110", '0', "0000000000000100"), --NOT tests
   ("0101", "00000000", "00000001", "11111111", '0', "0000000000000100"), --NOT tests
   ("0101", "10101010", "10101010", "01010101", '0', "0000000000000000"), --NOT tests - 30 ns
   ("0101", "01010101", "01010101", "10101010", '0', "0000000000000100"), --NOT tests
   ("0101", "11111111", "00000000", "00000000", '0', "0000000000000001"), --NOT tests
   ("0101", "11111111", "11111111", "00000000", '0', "0000000000000001"), --NOT tests
   ("0101", "00000000", "01010101", "11111111", '0', "0000000000000100"), --NOT tests
   ("0101", "00000000", "10101010", "11111111", '0', "0000000000000100"), --NOT tests - 35 ns
   ("0101", "11111111", "01010101", "00000000", '0', "0000000000000001"), --NOT tests
   ("0101", "11111111", "10101010", "00000000", '0', "0000000000000001"), --NOT tests
   ("0101", "10000011", "10110010", "01111100", '0', "0000000000000000"), --NOT tests
   ("0101", "00000011", "00110010", "11111100", '0', "0000000000000100"), --NOT tests - 39 ns

   ("0111", "00000000", "00000000", "00000000", '0', "0000000000000001"), --XOR tests - 40 ns
   ("0111", "00000001", "00000001", "00000000", '0', "0000000000000001"), --XOR tests
   ("0111", "00000000", "00000001", "00000001", '0', "0000000000000000"), --XOR tests
   ("0111", "10101010", "10101010", "00000000", '0', "0000000000000001"), --XOR tests
   ("0111", "01010101", "01010101", "00000000", '0', "0000000000000001"), --XOR tests
   ("0111", "11111111", "00000000", "11111111", '0', "0000000000000100"), --XOR tests - 45 ns
   ("0111", "11111111", "11111111", "00000000", '0', "0000000000000001"), --XOR tests
   ("0111", "00000000", "01010101", "01010101", '0', "0000000000000000"), --XOR tests
   ("0111", "00000000", "10101010", "10101010", '0', "0000000000000100"), --XOR tests
   ("0111", "11111111", "01010101", "10101010", '0', "0000000000000100"), --XOR tests
   ("0111", "11111111", "10101010", "01010101", '0', "0000000000000000"), --XOR tests - 50 ns
   ("0111", "10000011", "10110010", "00110001", '0', "0000000000000000"), --XOR tests
   ("0111", "00000011", "00110010", "00110001", '0', "0000000000000000")  --XOR tests
  );
begin
  --  Check each pattern.
  for i in patterns'range loop
    --  Set the inputs.
    Cin <= patterns(i).Cin;
    f <= patterns(i).f;
    rx <= patterns(i).rx;
    ry <= patterns(i).ry;
    --  Wait for the results.
    wait for 1 ns;
    --  Check the outputs.
    assert ro = patterns(i).ro
    report "bad output register value" severity error;
    assert sr = patterns(i).sr
    report "bad status register value" severity error;
    assert sr(0) = patterns(i).sr(0)
    report " *Zero is incorrect" severity error;
    assert sr(1) = patterns(i).sr(1)
    report " *Carry is incorrect" severity error;
    assert sr(2) = patterns(i).sr(2)
    report " *Negitive is incorrect" severity error;
  end loop;
  assert false report "end of test" severity note;
  --  Wait forever; this will finish the simulation.
  wait;
end process;
end behav;

