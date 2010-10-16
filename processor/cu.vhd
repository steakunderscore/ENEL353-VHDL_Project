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
--use work.fulladder;
--use work.cpu.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cu is
  Port (reset       : in STD_LOGIC;                       -- '0' for reset
        clock       : in STD_LOGIC;                       -- clock

        alu_f       : out STD_LOGIC_VECTOR (3 downto 0);  -- Function
        alu_Cin     : out STD_LOGIC;                      -- Carry in to ALU

        -- General Purpose Registers
        gpr_InSel   : out STD_LOGIC;                      -- select the input path (0 - cu, 1 - ALU)
        gpr_en      : out STD_LOGIC;                      -- enable write to GPR
        gpr_SelRx   : out STD_LOGIC_VECTOR (2 downto 0);  -- select GPR output x
        gpr_SelRy   : out STD_LOGIC_VECTOR (2 downto 0);  -- select GPR output y
        gpr_SelRi   : out STD_LOGIC_VECTOR (2 downto 0);  -- select GPR input
        gpr_Ri      : out STD_LOGIC_VECTOR (7 downto 0);  -- input to GPR
        gpr_Rx      : in STD_LOGIC_VECTOR (7 downto 0);   -- output Rx from GPR
        --gpr_Ry      : in STD_LOGIC_VECTOR (7 downto 0);   -- output Ry from GPR , not used

        -- Status Register
        sr_en       : out STD_LOGIC;                      -- enable write to SR
        sr_reset    : out STD_LOGIC;                      -- reset SR
        sr_Ro       : in STD_LOGIC_VECTOR (15 downto 0);  -- output from SR
        -- control unit doesnt write to SR, the ALU does
        
        -- Program Counter
        pc_en       : out STD_LOGIC;                      -- enable write to PC
        pc_reset    : out STD_LOGIC;                      -- reset PC
        pc_Ri       : out STD_LOGIC_VECTOR (15 downto 0); -- input to PC
        pc_Ro       : in STD_LOGIC_VECTOR (15 downto 0);  -- output from PC

        -- Address Registers
        ar_en       : out STD_LOGIC;                      -- enable write to AR
        ar_SelRi    : out STD_LOGIC_VECTOR (1 downto 0);  -- select AR in
        ar_SelRo    : out STD_LOGIC_VECTOR (1 downto 0);  -- select AR out
        ar_Ri       : out STD_LOGIC_VECTOR (15 downto 0); -- input to AR
        ar_Ro       : in STD_LOGIC_VECTOR (15 downto 0);  -- output from AR
        ar_sel8Bit  : out STD_LOGIC;                      -- only write half the AR
        ar_selHByte : out STD_LOGIC;                      -- high or low half of the AR to write
        ar_ByteIn   : out STD_LOGIC_VECTOR (7 downto 0);  -- 8 bit input to write half of AR

        -- Instruction memory
        inst_add    : out STD_LOGIC_VECTOR (11 downto 0); -- Instruction address
        inst_data   : in STD_LOGIC_VECTOR (15 downto 0);  -- Instruction data
        inst_req    : out STD_LOGIC;                      -- Request 
        inst_ack    : in STD_LOGIC;                       -- Instruction obtained

        data_add    : out STD_LOGIC_VECTOR (15 downto 0); -- Data address
        data_data   : inout STD_LOGIC_VECTOR (7 downto 0);-- Data
        data_read   : out STD_LOGIC;                      -- 1 for read, 0 for write
        data_req    : out STD_LOGIC;                      -- Request
        data_ack    : in STD_LOGIC                        -- Data written to/ read from

        );
end cu;


architecture Behavioral of cu is
  component fulladder16 IS
  Port (A    : in   STD_LOGIC_VECTOR(15 downto 0);
        B    : in   STD_LOGIC_VECTOR(15 downto 0);
        Cin  : in   STD_LOGIC;
        Sum  : out  STD_LOGIC_VECTOR(15 downto 0);
        Cout : out  STD_LOGIC
        );
  end component;

  type states is (reset_state, fetch, decode, execute);
  signal state      : states := reset_state;
  signal next_state : states := reset_state;

  signal opcode     : std_logic_vector(15 downto 0);  -- unprocessed instruction

  -- Decoded data
  signal rx : std_logic_vector(2 downto 0);
  signal ry : std_logic_vector(2 downto 0);
  signal ay : std_logic_vector(1 downto 0);

  -- Indicates what needs to be executed
  signal write_gpr    : std_logic;
  signal write_sr     : std_logic;
  signal write_pc     : std_logic;
  signal write_ar     : std_logic;
  signal write_memory : std_logic;

  -- full adders
  signal   A16         : std_logic_vector(15 downto 0);
  signal   B16         : std_logic_vector(15 downto 0);
  signal   AdderCin16  : std_logic;
  signal   Sum16       : std_logic_vector(15 downto 0);
  signal   AdderCout16 : std_logic;

  signal v    : STD_LOGIC_VECTOR(7 downto 0);  -- 8-bit immediate


BEGIN
  Adder16: fulladder16 port map(A16, B16, AdderCin16, Sum16, AdderCout16);

  -- Process instruction
  -- Assumes all instructions are valid
  process(clock, state, opcode, gpr_Rx, sr_Ro, pc_Ro, ar_Ro, inst_data, inst_ack, data_data, data_ack,
          rx, ry, ay, v, write_gpr, write_sr, write_pc, write_ar, write_memory)
  BEGIN
    if rising_edge(clock) then
      case state is
        when reset_state =>
          sr_reset <= '0';
          pc_reset <= '0';
          next_state <= fetch;

        when fetch =>
          gpr_en <= '0';
          sr_en <= '0';
          pc_en <= '0';
          ar_en <= '0';

          write_gpr <= '0';
          write_sr <= '0';
          write_pc <= '0';
          write_ar <= '0';
          write_memory <= '0';

          inst_add <= pc_Ro(11 downto 0);
          if inst_ack = '0' then
            inst_req <= '1';
          else
            opcode <= inst_data;
            inst_req <= '0';

            -- increment program counter
            AdderCin16 <= '1';
            A16 <= PC_Ro;
            B16 <= "0000000000000000";
            pc_Ri <= Sum16;
            pc_en <= '1';

            next_state <= decode;
          end if;
        when decode =>
          pc_en <= '0';

          -- ALU
          if opcode(15) = '0' and opcode(10) = '0' and not opcode(14 downto 11) = "0010" then

            ry <= opcode(7 downto 5);
            rx <= opcode(2 downto 0);

            gpr_SelRy <= ry;
            gpr_SelRx <= rx;
            gpr_SelRi <= ry;
            gpr_InSel <= '1';
            alu_f <= opcode(14 downto 11);
            alu_Cin <= sr_Ro(1);  -- Carry

            if not opcode(14 downto 11) = "0110" then -- CMP doesnt write to gpr, all others do
              write_gpr <= '1';
            end if;

            write_sr <= '1';
            next_state <= execute;

          -- Branching
          elsif opcode(11 downto 10) = "11" then

            v <= "00000000";  -- initialise v
            
            if opcode(15) = '1' then
              case opcode(14 downto 12) is
                when "000" => -- BEQ
                  if sr_Ro(0) = '1' then -- Z=1
                    v <= opcode(9 downto 2);
                  end if;
                when "001" => -- BNE
                  if sr_Ro(0) = '0' then -- Z=0
                    v <= opcode(9 downto 2);
                  end if;
                when "010" => -- BLT
                  if sr_Ro(0) = '0' and sr_Ro(2) = '1' then -- Z=0 and N=1
                    v <= opcode(9 downto 2);
                  end if;
                when "011" => -- BGT
                  if sr_Ro(0) = '0' and sr_Ro(2) = '0' then -- Z=0 and N=0
                    v <= opcode(9 downto 2);
                  end if;
                when "100" => -- BC
                  if sr_Ro(1) = '1' then -- C=1
                    v <= opcode(9 downto 2);
                  end if;
                when "101" => -- BNC
                  if sr_Ro(1) = '0' then -- C=0
                    v <= opcode(9 downto 2);
                  end if;
                when "110" => -- RJMP
                  v <= opcode(9 downto 2);

                when others =>
                  v <= "00000000";
              end case;      

              -- PC <- PC + v
              AdderCin16 <= '0';
              A16 <= PC_Ro;
              B16 <= "00000000" & v;
              pc_Ri <= Sum16;
              
            elsif opcode(15 downto 12) = "0111" then -- JMP
              ay <= opcode(6 downto 5);

              -- PC <- ay
              ar_SelRo <= ay;
              pc_Ri <= ar_Ro;
            else
              -- should not reach here
              pc_Ri <= pc_Ro; -- no change
            end if;

            write_pc <= '1';
            next_state <= execute;


          -- Addressing
          else
            gpr_Insel <= '0';

            case opcode(12 downto 10) is

              when "001" => -- Load
                if opcode(15) = '1' then  -- immediate
                  rx <= '0' & opcode(1 downto 0);
                  v <= opcode(9 downto 2);

                  -- rx <- v
                  gpr_SelRi <= rx;
                  gpr_Ri <= v;
                  write_gpr <= '1';
                  next_state <= execute;
                else                      -- direct
                  rx <= opcode(2 downto 0);
                  ay <= opcode(6 downto 5);

                  -- rx <- [ay]
                  gpr_SelRi <= rx;
                  ar_selRo <= ay;
                  data_add <= ar_Ro;
                  data_read <= '1';
                  if data_ack = '0' then  -- request data
                    data_req <= '1';
                  else                    -- data obtained
                    gpr_Ri <= data_data;
                    data_req <= '0';
                    write_gpr <= '1';
                    
                    case opcode(14 downto 13) is
                      when "01" =>            -- auto increment
                        AdderCin16 <= '1';
                        A16 <= ar_Ro;
                        B16 <= "0000000000000000";
                        ar_sel8bit <= '0';
                        ar_Ri <= Sum16;
                        write_ar <= '1';
                      when "10" =>            -- auto decrement
                        AdderCin16 <= '0';
                        A16 <= ar_Ro;
                        B16 <= "1111111111111111";
                        ar_sel8bit <= '0';
                        ar_Ri <= Sum16;
                        write_ar <= '1';
                      when others =>
                        -- do nothing
                    end case;
                    next_state <= execute;
                  end if;
                end if;

              when "101" => -- Store
                if opcode(15) = '1' then  -- immediate
                  ay <= opcode(1 downto 0);
                  v <= opcode(9 downto 2);

                  -- [ay] <- v
                  ar_selRo <= ay;
                  data_add <= ar_Ro;
                  data_read <= '0';
                  data_data <= v;
                  write_memory <= '1';
                  next_state <= execute;
                else                      -- direct
                  rx <= opcode(2 downto 0);
                  ay <= opcode(6 downto 5);

                  -- [ay] <- rx
                  gpr_selRx <= rx;
                  ar_selRo <= ay;
                  data_add <= ar_Ro;
                  data_read <= '0';
                  data_data <= gpr_Rx;
                  write_memory <= '1';

                  case opcode(14 downto 13) is
                    when "01" =>            -- auto increment
                      AdderCin16 <= '1';
                      A16 <= ar_Ro;
                      B16 <= "0000000000000000";
                      ar_sel8bit <= '0';
                      ar_Ri <= Sum16;
                      write_ar <= '1';
                    when "10" =>            -- auto decrement
                      AdderCin16 <= '0';
                      A16 <= ar_Ro;
                      B16 <= "1111111111111111";
                      ar_sel8bit <= '0';
                      ar_Ri <= Sum16;
                      write_ar <= '1';
                    when others =>
                      -- do nothing
                  end case;
                  next_state <= execute;
                end if;

              when "100" => -- Move
                if opcode(9) = '1' then
                  rx <= opcode(2 downto 0);
                  ay <= opcode(6 downto 5);

                  -- ayn <- rx
                  gpr_selRx <= rx;
                  ar_selRo <= ay;
                  ar_sel8bit <= '1';
                  ar_ByteIn <= gpr_Rx;

                  if opcode(8) = '1' then     -- high
                    ar_selHByte <= '1';
                  else                        -- low
                    ar_selHByte <= '0';
                  end if;

                  write_ar <= '1';
                  next_state <= execute;

                elsif opcode(4) = '1' then
                  rx <= opcode(7 downto 5);
                  ay <= opcode(1 downto 0);

                  -- rx <- ayn
                  gpr_selRi <= rx;
                  ar_selRo <= ay;

                  if opcode(3) = '1' then     -- high
                    gpr_Ri <= ar_Ro(15 downto 8);
                  else                        -- low
                    gpr_Ri <= ar_Ro(7 downto 0);
                  end if;

                  write_gpr <= '1';
                  next_state <= execute;

                else   
                  rx <= opcode(2 downto 0);
                  ry <= opcode(7 downto 5);

                  -- ry <- rx
                  gpr_SelRx <= rx;
                  gpr_SelRi <= ry;
                  gpr_Ri <= gpr_Rx;

                  write_gpr <= '1';
                  next_state <= execute;

                end if;


              when others =>
                -- should not reach here

            end case;

          end if;

        when others =>  -- execute
          gpr_en <= write_gpr;
          sr_en <= write_sr;
          pc_en <= write_pc;
          ar_en <= write_ar;
          if write_memory = '1' then
            if data_ack = '0' then  -- request write
              data_req <= '1';
            else                    -- data written
              data_req <= '0';
              next_state <= fetch;
            end if;
          else
            next_state <= fetch;
          end if;
      end case;
    end if;
  end process;

  process(clock, reset, next_state)
  BEGIN
    if reset = '0' then
      state <= reset_state;
    elsif rising_edge(clock) then
      state <= next_state;
    end if;
  end process;

end Behavioral;

