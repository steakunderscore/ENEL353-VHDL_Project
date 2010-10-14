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
        gpr_InSel   : out STD_LOGIC;                      -- select the input path (0 - cu, 1 - ALU)
        gpr_en      : out STD_LOGIC;                      -- enable write to GPR
        gpr_SelRx   : out STD_LOGIC_VECTOR (2 downto 0);  -- select GPR output x
        gpr_SelRy   : out STD_LOGIC_VECTOR (2 downto 0);  -- select GPR output y
        gpr_SelRi   : out STD_LOGIC_VECTOR (2 downto 0);  -- select GPR input
        gpr_Ri      : out STD_LOGIC_VECTOR (7 downto 0); -- input to GPR
        gpr_Rx      : out STD_LOGIC_VECTOR (7 downto 0); -- Rx to GPR
        gpr_Ry      : out STD_LOGIC_VECTOR (7 downto 0); -- Ry to GPR

        -- Special Purpose Register
        spr_en      : out STD_LOGIC;                      -- enable write to SPR
        spr_Ro      : in STD_LOGIC_VECTOR (15 downto 0);  -- output from SPR
        -- control unit doesnt write to SPR, the ALU does
        
        -- Program Counter
        pc_en       : out STD_LOGIC;                      -- enable write to PC
        pc_Ri       : out STD_LOGIC_VECTOR (15 downto 0); -- input to PC
        pc_Ro       : in STD_LOGIC_VECTOR (15 downto 0);  -- output from PC

        -- Address Registers
        ar_en       : out STD_LOGIC;                      -- enable write to AR
        ar_SelRi    : out STD_LOGIC_VECTOR (1 downto 0);  -- select AR in
        ar_SelRo    : out STD_LOGIC_VECTOR (1 downto 0);  -- select AR out
        ar_Ri       : out STD_LOGIC_VECTOR (15 downto 0); -- input to AR
        ar_Ro       : in STD_LOGIC_VECTOR (15 downto 0)   -- output from AR

        );
end cu;


architecture Behavioral of cu is
  component fulladder8 IS
  Port (A    : in   STD_LOGIC_VECTOR(7 downto 0);
        B    : in   STD_LOGIC_VECTOR(7 downto 0);
        Cin  : in   STD_LOGIC;
        Sum  : out  STD_LOGIC_VECTOR(7 downto 0);
        Cout : out  STD_LOGIC
        );
  end component;
  signal   A         : std_logic_vector(7 downto 0);
  signal   B         : std_logic_vector(7 downto 0);
  signal   AdderCin  : std_logic;
  signal   Sum       : std_logic_vector(7 downto 0);
  signal   AdderCout : std_logic;

  signal v    : STD_LOGIC_VECTOR(7 downto 0);  -- 8-bit immediate

  -- Makes code easier to read
  signal rx : std_logic_vector(2 downto 0);
  signal ry : std_logic_vector(2 downto 0);
  signal ay : std_logic_vector(1 downto 0);

BEGIN
  Adder: fulladder8 port map(A, B, AdderCin, Sum, AdderCout);

  -- Process instruction
  -- Assumes all instructions are valid
  process(opcode)
  BEGIN

    -- Disable writing to all registers at start
    gpr_en <= '0';
    spr_en <= '0';
    pc_en <= '0';
    ar_en <= '0';

    -- ALU
    if opcode(15) = '0' and opcode(10) = '0' and not opcode(14 downto 11) = "0010" then

      ry <= opcode(7 downto 5);
      rx <= opcode(2 downto 0);

      gpr_SelRy <= ry;
      gpr_SelRx <= rx;
      gpr_SelRi <= ry;
      gpr_InSel <= '1';
      alu_f <= opcode(14 downto 11);

      if opcode(14 downto 11) = "0110" then -- CMP doesnt write to gpr
        gpr_en <= '0';
      else                                  -- all others do
        gpr_en <= '1';
      end if;

      spr_en <= '1';

      -- TODO need some way to indicate write complete
      --gpr_en <= '0';
      --spr_en <= '0';

    -- Branching
    elsif opcode(11 downto 10) = "11" then

      v <= "00000000";  -- initialise v
      
      if opcode(15) = '1' then
        case opcode(14 downto 12) is
          when "000" => -- BEQ
            if spr_Ro(0) = '1' then -- Z=1
              v <= opcode(9 downto 2);
            end if;
          when "001" => -- BNE
            if spr_Ro(0) = '0' then -- Z=0
              v <= opcode(9 downto 2);
            end if;
          when "010" => -- BLT
            if spr_Ro(0) = '0' and spr_Ro(2) = '1' then -- Z=0 and N=1
              v <= opcode(9 downto 2);
            end if;
          when "011" => -- BGT
            if spr_Ro(0) = '0' and spr_Ro(2) = '0' then -- Z=0 and N=0
              v <= opcode(9 downto 2);
            end if;
          when "100" => -- BC
            if spr_Ro(1) = '1' then -- C=1
              v <= opcode(9 downto 2);
            end if;
          when "101" => -- BNC
            if spr_Ro(1) = '0' then -- C=0
              v <= opcode(9 downto 2);
            end if;
          when "110" => -- RJMP
            v <= opcode(9 downto 2);

          when others =>
            v <= "00000000";
        end case;      

        -- PC <- PC + v
        -- TODO make lengths compatible - 8 bit and 16 bit
        AdderCin <= '0';
        A <= PC_Ro;
        B <= v;
        pc_Ri <= Sum;
        
      elsif opcode(15 downto 12) = "0111" then -- JMP
        ay <= opcode(6 downto 5);

        -- PC <- ay
        ar_SelRo <= ay;
        pc_Ri <= ar_Ro;
      else
        pc_Ri <= pc_Ro; -- no change
      end if;

      pc_en <= '1';

      -- TODO need some way to indicate write complete
      pc_en <= '0';


    -- Addressing
    else
      gpr_Insel <= '0';

      case opcode(12 downto 10) is

        when "001" => -- Load
          if opcode(15) = '1' then  -- immediate
            rx <= 0 & opcode(1 downto 0);
            v <= opcode(9 downto 2);

            -- rx <- v
            gpr_SelRi <= rx;
            gpr_Ri <= v;
          else                      -- direct
            rx <= opcode(2 downto 0);
            ay <= opcode(6 downto 5);

            -- TODO rx <- ay
          end if;

          gpr_en <= '1';
          
          -- TODO need some way to indicate write complete
          gpr_en <= '0';


          case opcode(14 downto 13) is
            when "01" =>            -- auto increment
              ay <= opcode(6 downto 5);

              -- TODO increment AR

            when "10" =>            -- auto decrement
              ay <= opcode(6 downto 5);

              -- TODO decrement AR 

            when others =>
              -- do nothing
          end case;

        when "101" => -- Store
          if opcode(15) = '1' then  -- immediate
            ay <= opcode(1 downto 0);
            v <= opcode(9 downto 2);

            -- TODO [ay] <- v

          else                      -- direct
            rx <= opcode(2 downto 0);
            ay <= opcode(6 downto 5);

            -- TODO [ay] <- rx
          end if;

          case opcode(14 downto 13) is
            when "01" =>            -- auto increment
              ay <= opcode(6 downto 5);
              -- TODO increment AR

            when "10" =>            -- auto decrement
              ay <= opcode(6 downto 5);
              -- TODO decrement AR 

            when others =>
              -- do nothing
          end case;


        when "100" => -- Move
          if opcode(9) = '1' then       -- MV ay(HL), rx

          elsif opcode(4) = '1' then    -- MV rx, ay(HL)

          else   
            rx <= opcode(2 downto 0);
            ry <= opcode(7 downto 5);

            -- ry <- rx
            gpr_SelRx <= rx;
            gpr_SelRi <= ry;

            gpr_en <= '1';

            -- TODO need some way to indicate write complete
            gpr_en <= '0';

          end if;


        when others =>
          ar_en <= '0';

      end case;

      -- TODO need some way to indicate write complete
      ar_en <= '0';


    end if;

  end process;
end Behavioral;

