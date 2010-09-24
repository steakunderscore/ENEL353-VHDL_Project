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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
   Port (clk : in   STD_LOGIC;                      -- Clock
         f   : in   STD_LOGIC_VECTOR (3 downto 0);  -- Function (opcode)
         rx  : in   STD_LOGIC_VECTOR (7 downto 0);  -- Input x (Rx)
         ry  : in   STD_LOGIC_VECTOR (7 downto 0);  -- Input y (Ry)
         ro  : out  STD_LOGIC_VECTOR (7 downto 0);  -- Output Normaly (Ry)
         Cin : in   STD_LOGIC;                      -- Carry in
         sr  : out  STD_LOGIC_VECTOR (2 downto 0)); -- Status register out {Z,C,N}
end alu;

architecture Behavioral of alu is

begin
  process(clk, f, rx, ry, Cin)
  begin
  
  -- use case statement to achieve 
  -- different operations of ALU

  if (clk='1' and clk'event) then
    case f(0) is
      when '1' => -- '1' means that it is a arithmetic or logic function
        case f(3 downto 1) is
          case f(3) is
            
            when '0' => -- It is a logic function
              case f(2 downto 1) is
                when "00" => -- Do AND operation
                  ro <= ry and rx;
                when "01" => -- Do OR  operation
                  ro <= ry or rx;
                when "10" => -- Do NOT operation
                  ro <= not rx;
                when "11" => -- Do XOR operation
                  ro <= ry xor rx;
              end case;
              if (ro = "00000000") then -- Set the status register
                sr(0) <= '0';
              end if;
              sr(1) <= '0';
              sr(2) <= ro(7); -- This might need to be changed to '0'

            when '1' => -- It is a arithmetic function
              case f(2 downto 1) is
                when "00" => -- Do ADD operation
                  ro <= ry + rx;
                when "01" => -- Do ADC operation
                  ro <= ry + rx + Cin;
                when "10" => -- Do SUB operation
                  ro <= ry - rx;
                when "11" => -- Do SBB operation
                  ro <= (ry - rx - Cin);
              end case;

        end case;
      when '0' => -- the other functions
        case f(3 downto 1) is
          when "010" => -- Do NEG operation ( two's complement )
            ro <= ((not rx) + 1);
            -- TODO: Add the status register output
          when "011" => -- Do CMP operation
            if ( ry > rx ) then
              ro <= ry;
            else
              ro <= rx;
            end if;
            if (ro = "00000000") then
              sr(0) <= '0';
              sr(1) <= '0';
              sr(2) <= ro(7); -- This might need to be changed to '0'
            end if;
        end case;
      when others =>
        ro <= "XXXXXXXX";
    end case;
  end if;

  end process;

end Behavioral;

