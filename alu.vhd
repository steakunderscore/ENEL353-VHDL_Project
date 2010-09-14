----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:59:20 09/18/2010 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    Port ( opcode : in   STD_LOGIC_VECTOR (3 downto 0);
           rx     : in   STD_LOGIC_VECTOR (7 downto 0);
           ry     : in   STD_LOGIC_VECTOR (7 downto 0);
           ro     : out  STD_LOGIC_VECTOR (7 downto 0);
           Z      : out  STD_LOGIC;
           Cin    : in   STD_LOGIC; -- Caarry in
           Cout   : out  STD_LOGIC; -- Carry out
           N      : out  STD_LOGIC);
end alu;

architecture Behavioral of alu is

begin
    process(Cin, ry, rx, opcode)
    begin
    
    -- use case statement to achieve 
    -- different operations of ALU

    case opcode is
        when "0001" => -- Do AND operation
				ro <= ry and rx;
        when "0011" => -- Do OR  operation
		      ro <= ry or rx;
        when "0101" => -- Do NOT operation
		      ro <= not rx;
        when "0111" => -- Do XOR operation
		      ro <= ry xor rx;
        when "1001" => -- Do ADD operation
		      ro <= ry + rx;
        when "1011" => -- Do ADC operation
		      --ro <= ry + rx + Cin;
        when "1101" => -- Do SUB operation
		      ro <= ry - rx;
        when "1111" => -- Do SBB operation
		      --ro <= (ry - rx - Cin);
        when "0100" => -- Do NEG operation ( two's complement )
		      --ro <= ((not rx) + 1);
        when "0110" => -- Do CMP operation
		      if ( ry > rx ) then
				    ro <= ry;
		      else
					 ro <= rx;
			   end if;
        when others =>
            ro <= "XXXXXXXX";
    end case;

    end process;

end Behavioral;

