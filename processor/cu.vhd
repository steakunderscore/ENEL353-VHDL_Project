----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:  18:59:20 09/18/2010 
-- Design Name: 
-- Module Name:  cu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: The control unit
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
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;


library work;
--use work.cpu.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cu is
  Port (opcode      : in  STD_LOGIC_VECTOR (15 downto 0); -- the instruction opcode
        alu_f       : out STD_LOGIC_VECTOR (3 downto 0);  -- Function

        -- General Purpose Registers
        gpr_en      : out STD_LOGIC;                      -- enable write to GPR
        gpr_SelRx   : out STD_LOGIC_VECTOR (2 downto 0);  -- select GPR output x
        gpr_SelRy   : out STD_LOGIC_VECTOR (2 downto 0);  -- select GPR output y
        gpr_SelRi   : out STD_LOGIC_VECTOR (2 downto 0);  -- select GPR input

        -- Special Purpose Register
        spr_en      : out STD_LOGIC;                      -- enable write to SPR
        spr_Ro      : in STD_LOGIC_VECTOR (15 downto 0);  -- Ro from SPR
        
        -- Program Counter
        pc_en       : out STD_LOGIC;                      -- enable write to PC
        pc_Ri       : out STD_LOGIC_VECTOR (15 downto 0); -- input to PC
        pc_Ro       : in STD_LOGIC_VECTOR (15 downto 0);  -- output from PC

        -- Address Registers
        ar_en       : out STD_LOGIC;                      -- enable write to AR
        ar_SelRi    : out STD_LOGIC_VECTOR (1 downto 0);  -- select AR in
        ar_SelRo    : out STD_LOGIC_VECTOR (1 downto 0)   -- select AR out

        );
end cu;


architecture Behavioral of cu is
BEGIN

  -- Process instruction
  process(opcode)
    variable v    : STD_LOGIC_VECTOR (7 downto 0);  -- 8-bit immediate
    variable temp : STD_LOGIC_VECTOR (7 downto 0);
  BEGIN

    -- ALU
    if opcode(15) = '0' and opcode(10) = '0' and not opcode(14 downto 11) = "0010" then

      if opcode(14 downto 11) = "0110" then -- CMP doesnt write to gpr
        gpr_en <= '0';
      else                                  -- all others do
        gpr_en <= '1';
      end if;

      spr_en <= '1';
      pc_en <= '0';
      ar_en <= '0';

      alu_f <= opcode(14 downto 11);
      gpr_SelRy <= opcode(7 downto 5);
      gpr_SelRx <= opcode(2 downto 0);
      gpr_SelRi <= opcode(7 downto 5);

    -- Branching
    elsif opcode(11 downto 10) = "11" then
      alu_f <= "0000";
      gpr_en <= '0';
      spr_en <= '0';
      pc_en <= '1';
      ar_en <= '0';
      

      if opcode(15) = '1' then
        case opcode(14 downto 12) is
          when "000" => -- BEQ
            if spr_Ro(0) = '1' then -- Z=1
              v := opcode(9 downto 2);
            end if;
          when "001" => -- BNE
            if spr_Ro(0) = '0' then -- Z=0
              v := opcode(9 downto 2);
            end if;
          when "010" => -- BLT
            if spr_Ro(0) = '0' and spr_Ro(2) = '1' then -- Z=0 and N=1
              v := opcode(9 downto 2);
            end if;
          when "011" => -- BGT
            if spr_Ro(0) = '0' and spr_Ro(2) = '0' then -- Z=0 and N=0
              v := opcode(9 downto 2);
            end if;
          when "100" => -- BC
            if spr_Ro(1) = '1' then -- C=1
              v := opcode(9 downto 2);
            end if;
          when "101" => -- BNC
            if spr_Ro(1) = '0' then -- C=0
              v := opcode(9 downto 2);
            end if;
          when "110" => -- RJMP
            v := opcode(9 downto 2);

          when others =>
            v := "00000000";
        end case;
        
        -- TODO needs adders
        --PC_Ri <= PC_Ro + v;

      elsif opcode(15 downto 12) = "0111" then -- JMP
        -- TODO
        
      end if;


    -- Addressing
    else
      alu_f <= "0000";
      gpr_en <= '0';
      spr_en <= '0';
      pc_en <= '0';

      case opcode(12 downto 10) is

        -- TODO : complete addressing
      
        when "001" => -- Load
          ar_en <= '0';


        when "101" => -- Store
          ar_en <= '1';


        when "100" => -- Move
          ar_en <= '1';


        when others =>
          ar_en <= '0';

      end case;
    end if;

  end process;
end Behavioral;

