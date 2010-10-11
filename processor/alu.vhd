----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:  18:59:20 09/18/2010 
-- Design Name: 
-- Module Name:  alu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;


library work;
use WORK.NUMERIC_STD.ALL;
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
        sr  : out  STD_LOGIC_VECTOR (2 downto 0)); -- Status register out Z(0), C(1), N(2)
end alu;


architecture Behavioral of alu is
  signal   temp   : std_logic_vector(8 downto 0); -- Used so addition with carry can occour
BEGIN
  process(f, rx, ry, Cin)
    variable output : std_logic_vector(7 downto 0); -- used to allow reading of ro
    variable Z,C,N  : std_logic; -- Make the code easier to read
  BEGIN
    -- use case statement to achieve 
    -- different operations of ALU

    case f(0) is
      when '1' => -- '1' means that it is a arithmetic or logic function
        case f(3) is --seperate the arithmetic and logic function
          when '0' => -- It is a logic function
            case f(2 downto 1) is
              when "00" => -- Do AND operation
                output := ry and rx;
              when "01" => -- Do OR  operation
                output := ry or rx;
              when "10" => -- Do NOT operation
                output := not rx;
              when "11" => -- Do XOR operation
                output := ry xor rx;
              when others =>
                output := (others => '0');
            end case;
            if (output = "00000000") then -- Set the Zero in status register
              Z := '1';
            ELSE
              Z := '0';
            end if;
            C := '0'; -- Carry is always 0
            N := output(7); -- This might need to be changed to '0'

          when '1' => -- It is a arithmetic function
            case f(2 downto 1) is
              when "00" => -- Do ADD operation
                temp <= ( '0' & ry ) + ( '0' & rx );
              when "01" => -- Do ADC operation
                temp <= ( '0' & ry ) + ( '0' & rx ) + ( "00000000" & Cin ); --TODO: check this logic
              when "10" => -- Do SUB operation
                temp <= ry - rx;
              when "11" => -- Do SBB operation
                temp <= ( '0' & ry ) - ( '0' & rx ) - ( "00000000" & Cin ); --TODO: check this logic
              when others =>
                output := (others => '0');
            end case;
            output := temp(7 downto 0);
            if (output = "00000000") then -- Set the Zero in status register
              Z := '1';
            ELSE
              Z := '0';
            end if;
            C := temp(8);
            N := temp(7);
          when others =>
            output := (others => '0');
        end case;
      when '0' => -- Non arithmetic or locic
        case f(3 downto 1) is
          when "010" => -- Do NEG operation ( two's complement )
            output := ((not rx) + "00000001");
            -- TODO: Add the status register output
          when "011" => -- Do CMP operation
            if ( ry > rx ) then
              output := ry;
            else
              output := rx;
            end if;
            if (output = "00000000") then
              Z := '0';
            end if;
            C := '0';
            N := output(7); -- This might need to be changed to '0'
          when others =>
            output := (others => '0');
        end case;
      when others =>
        output := (others => '0');
    end case;  --  f(0)
    ro <= output;
    sr(0) <= Z; --Z(0)
    sr(1) <= C; --C(1)
    sr(2) <= N; --N(2)

  end process;
end Behavioral;

