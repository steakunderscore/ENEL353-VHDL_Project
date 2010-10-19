-- Authors:
--      Henry Jenkins, Joel Koh

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;


library work;
--use work.fulladder8;
--use work.cpu.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
  Port (f   : in   STD_LOGIC_VECTOR (3 downto 0);  -- Function (opcode)
        rx  : in   STD_LOGIC_VECTOR (7 downto 0);  -- Input x (Rx)
        ry  : in   STD_LOGIC_VECTOR (7 downto 0);  -- Input y (Ry)
        ro  : out  STD_LOGIC_VECTOR (7 downto 0);  -- Output Normaly (Ry)
        Cin : in   STD_LOGIC;                      -- Carry in
        sr  : out  STD_LOGIC_VECTOR (15 downto 0)); -- Status register out Z(0), C(1), N(2)
end alu;


architecture alu_arch of alu is
  component fulladder8 IS
  Port (A    : in   STD_LOGIC_VECTOR( 7 downto 0);
        B    : in   STD_LOGIC_VECTOR( 7 downto 0);
        Cin  : in   STD_LOGIC;
        Sum  : out  STD_LOGIC_VECTOR( 7 downto 0);
        Cout : out  STD_LOGIC
        );
  end component;
  signal   A         : std_logic_vector(7 downto 0);
  signal   B         : std_logic_vector(7 downto 0);
  signal   AdderCin  : std_logic;
  signal   Sum       : std_logic_vector(7 downto 0);
  signal   AdderCout : std_logic;
  signal   Z,C,N     : std_logic; -- Make the code easier to read
  signal   output    : std_logic_vector(7 downto 0); -- used to allow reading of ro
BEGIN
  Adder: fulladder8 port map(A, B, AdderCin, Sum, AdderCout);
  process(f, rx, ry, Cin, Sum, AdderCout)
    --signal Z,C,N  : std_logic; -- Make the code easier to read
  BEGIN
    -- use case statement to achieve 
    -- different operations of ALU

      AdderCin <= '0';
      A <= (others => '0');
      B <= (others => '0');
      output <= (others => '0');
      C <= '0';
      N <= '0';
      IF f = "0001" THEN -- Do AND operation
         output <= ry and rx;
      ELSIF f = "0011" THEN -- Do OR  operation
        output <= ry or rx;
      ELSIF f = "0101" THEN
        output <= not rx;
      ELSIF f = "0111" THEN -- Do XOR operation
        output <= ry xor rx;
      ELSIF f = "1001" THEN -- Do ADD operation
        AdderCin <= '0';
        A <= ry;
        B <= rx;
        output <= Sum;
      ELSIF f = "1011" THEN -- Do ADC operation
        AdderCin <= Cin;
        A <= ry;
        B <= rx;
        output <= Sum;
      ELSIF f = "1101" THEN -- Do SUB operation
        AdderCin <= '1';
        A <= ry;
        B <= (not rx);
        output <= Sum;
      ELSIF f = "1111" THEN -- Do SBB operation
        AdderCin <= (not Cin);
        A <= ry;
        B <= (not rx);
        output <= Sum;
      ELSIF f = "0100" THEN -- Do NEG operation ( two's complement )
        AdderCin <= '1';
        A <= (others => '0');
        B <= (not rx);
        output <= Sum;
        C <= AdderCout;
        N <= output(7);
      ELSIF f = "0110" THEN -- Do CMP operation
        AdderCin <= '1';
        A <= rx;
        B <= (not ry);
        output <= Sum;
        C <= AdderCout;
        N <= output(7);
      ELSE
        AdderCin <= '0';
        A <= (others => '0');
        B <= (others => '0');
        output <= (others => '0');
        C <= '0';
        N <= '0';
      END IF;
--    if (output = "00000000") then -- Set the Zero in status register
--      sr(0) <= '1';
--    ELSE
--      sr(0) <= '0';
--    end if;
      
      C <= AdderCout; -- Carry is always 0
      N <= output(7); -- This might need to be changed to '0'
      ro <= output;
  end process;
    Z <= not (output(0) AND output(1) AND output(2) AND output(3) AND output(4)
              AND output(5) AND output(6) AND output(7));
    sr(0) <= Z; --Z(0)
    sr(1) <= C; --C(1)
    sr(2) <= N; --N(2)
    sr(15 downto 3) <= (others => '0');

end alu_arch;
