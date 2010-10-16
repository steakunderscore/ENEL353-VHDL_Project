----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:09:46 09/15/2010 
-- Design Name: 
-- Module Name:    cpu - cpu_arch 
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
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.alu;
use work.cu;
use work.ar;
use work.gpr;
use work.sr;
use work.pc;


---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is

  PORT(
      -- instruction bus
      inst_add  : out std_logic_vector(11 downto 0); -- Address lines.
      inst_data : in  std_logic_vector(15 downto 0); -- Data lines.
      inst_req  : out std_logic;                     -- Pulled low to request bus usage.
      inst_ack  : in  std_logic;                     -- Pulled high to inform of request completion.
      -- data bus
      data_add  : out    std_logic_vector(15 downto 0); -- Address lines.
      data_line : inout std_logic_vector(7 downto 0);  -- Data lines.
      data_read : out    std_logic;                     -- High for a read request, low for a write request.
      data_req  : out    std_logic;                     -- Pulled low to request bus usage.
      data_ack  : inout std_logic;                     -- Pulled high to inform of request completion.
      -- extras
      clk       : in  std_logic;
      reset     : in  std_logic
    );

end cpu;

architecture cpu_arch of cpu is
  component alu IS
    Port (f   : in   STD_LOGIC_VECTOR (3 downto 0);  -- Function (opcode)
          rx  : in   STD_LOGIC_VECTOR (7 downto 0);  -- Input x (Rx)
          ry  : in   STD_LOGIC_VECTOR (7 downto 0);  -- Input y (Ry)
          ro  : out  STD_LOGIC_VECTOR (7 downto 0);  -- Output Normaly (Ry)
          Cin : in   STD_LOGIC;                      -- Carry in
          sr  : out  STD_LOGIC_VECTOR (15 downto 0)); -- Status register out Z(0), C(1), N(2)
  END component;
  component ar is
    Port (clk         : in   STD_LOGIC;
          enable      : in   STD_LOGIC;
          Sel8Bit     : in   STD_LOGIC;
          SelHighByte : in   STD_LOGIC;
          ByteInput   : in   STD_LOGIC_VECTOR (7 downto 0);
          SelRi       : in   STD_LOGIC_VECTOR (1 downto 0);   -- Select the address register
          SelRo       : in   STD_LOGIC_VECTOR (1 downto 0);   -- Select the address register
          Ri          : in   STD_LOGIC_VECTOR (15 downto 0);  -- The input
          Ro          : out  STD_LOGIC_VECTOR (15 downto 0)); -- The output
  END component;
  component cu IS
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
  END component;
  component gpr is
    Port (clk      : in   STD_LOGIC;
          enable   : in   STD_LOGIC;
          SelRx    : in   STD_LOGIC_VECTOR (2 downto 0);  -- The Rx output selection value
          SelRy    : in   STD_LOGIC_VECTOR (2 downto 0);  -- The Ry output selection value
          SelRi    : in   STD_LOGIC_VECTOR (2 downto 0);  -- The Ri input selection value
          SelIn    : in   STD_LOGIC;  -- Select where the input should be from the CU or CDB
          RiCU     : in   STD_LOGIC_VECTOR (7 downto 0);  -- Input from the Control Unit
          RiCDB    : in   STD_LOGIC_VECTOR (7 downto 0);  -- Input from the Common Data Bus
          Rx       : out  STD_LOGIC_VECTOR (7 downto 0);  -- The Rx output
          Ry       : out  STD_LOGIC_VECTOR (7 downto 0)); -- The Ry output
  END component;
  component sr is
    Port (clk      : in  STD_LOGIC;
          enable   : in  STD_LOGIC;
          reset    : in  STD_LOGIC;
          Ri       : in  STD_LOGIC_VECTOR (15 downto 0);  -- The input to the SR
          Ro       : out STD_LOGIC_VECTOR (15 downto 0)); -- The output from SR
  END component;
  component pc is
    Port (clk      : in  STD_LOGIC;
          enable   : in  STD_LOGIC;
          reset    : in  STD_LOGIC;
          Ri       : in  STD_LOGIC_VECTOR (15 downto 0);  -- The input to the SR
          Ro       : out STD_LOGIC_VECTOR (15 downto 0)); -- The output from SR
  END component;
  signal alu_Cin    : std_logic;
  signal alu_f      : std_logic_vector(3 downto 0);
  signal alu_rx     : std_logic_vector(7 downto 0);
  signal alu_ry     : std_logic_vector(7 downto 0);

  signal sr_reset   : std_logic;
  signal sr_enable  : std_logic;
  signal sr_Ro      : std_logic_vector(15 downto 0);
  signal sr_input   : std_logic_vector(15 downto 0);

  signal ar_enable   : STD_LOGIC;                      -- enable write to AR
  signal ar_SelRi    : STD_LOGIC_VECTOR (1 downto 0);  -- select AR in
  signal ar_SelRo    : STD_LOGIC_VECTOR (1 downto 0);  -- select AR out
  signal ar_Ri       : STD_LOGIC_VECTOR (15 downto 0); -- input to AR
  signal ar_Ro       : STD_LOGIC_VECTOR (15 downto 0);  -- output from AR
  signal ar_sel8Bit  : STD_LOGIC;                      -- only write half the AR
  signal ar_selHByte : STD_LOGIC;                      -- high or low half of the AR to write
  signal ar_ByteIn   : STD_LOGIC_VECTOR (7 downto 0);  -- 8 bit input to write half of AR

  signal pc_reset   : std_logic;
  signal pc_enable  : std_logic;
  signal pc_Ri      : std_logic_vector(15 downto 0);
  signal pc_Ro      : std_logic_vector(15 downto 0);

  signal gpr_InSel  : std_logic;
  signal gpr_enable : std_logic;
  signal gpr_SelRx  : std_logic_vector(2 downto 0);
  signal gpr_SelRy  : std_logic_vector(2 downto 0);
  signal gpr_SelRi  : std_logic_vector(2 downto 0);
  signal gpr_RiCU   : std_logic_vector(7 downto 0);
  signal gpr_RiCDB  : std_logic_vector(7 downto 0);
begin

  a: alu port map(
            f    => alu_f,
            rx   => alu_rx,
            ry   => alu_ry,
            ro   => gpr_RiCDB,
            Cin  => alu_Cin,
            sr   => sr_input
           );
  c: cu port map(

            reset     => reset,-- '0' for reset
            clock     => clk,-- clock

            alu_f     => alu_f,-- Function
            alu_Cin   => alu_Cin, -- Carry into the ALU

            -- General Purpose Registers
            gpr_InSel => gpr_InSel,-- select the input path (0 - cu, 1 - ALU)
            gpr_en    => gpr_enable,-- enable write to GPR
            gpr_SelRx => gpr_SelRx,-- select GPR output x
            gpr_SelRy => gpr_SelRy,-- select GPR output y
            gpr_SelRi => gpr_SelRi,-- select GPR input
            gpr_Ri    => gpr_RiCU,-- input to GPR
            gpr_Rx    => alu_rx,-- Rx from GPR
            --gpr_Ry    => alu_ry,-- Ry from GPR

            -- Status Register
            sr_en     => sr_enable,-- enable write to SR
            sr_reset  => sr_reset,-- reset SR
            sr_Ro     => sr_Ro,-- output from SR
            -- control unit doesnt write to SR, the ALU does

            -- Program Counter
            pc_en     => pc_enable,-- enable write to PC
            pc_reset  => pc_reset,-- reset PC
            pc_Ri     => pc_Ri,-- input to PC
            pc_Ro     => pc_Ro,-- output from PC

            -- Address Registers
            ar_en       => ar_enable,   -- enable write to AR
            ar_SelRi    => ar_SelRi,    -- select AR in
            ar_SelRo    => ar_SelRo,    -- select AR out
            ar_sel8Bit  => ar_sel8Bit,
            ar_selHByte => ar_selHByte,
            ar_ByteIn   => ar_ByteIn,
            ar_Ri       => ar_Ri,       -- input to AR
            ar_Ro       => ar_Ro,       -- output from AR

            -- Instruction memory
            inst_add  => inst_add ,-- Instruction address
            inst_data => inst_data,-- Instruction data
            inst_req  => inst_req ,-- Request 
            inst_ack  => inst_ack ,-- Instruction obtained

            data_add  => data_add ,-- Data address
            data_data => data_line,-- Data
            data_read => data_read,-- 1 for read, 0 for write
            data_req  => data_req ,-- Request
            data_ack  => data_ack  -- Data written to/ read from
          );
  address : ar port map(
            clk         => clk,
            enable      => ar_enable,
            Sel8Bit     => ar_Sel8Bit,
            SelHighByte => ar_selHByte,
            ByteInput   => ar_ByteIn,
            SelRi       => ar_SelRi,
            SelRo       => ar_SelRo,
            Ri          => ar_Ri,
            Ro          => ar_Ro
          );
g : gpr port map(
            clk    => clk,
            enable => gpr_enable,
            SelRx  => gpr_SelRx,
            SelRy  => gpr_SelRy,
            SelRi  => gpr_SelRi,
            SelIn  => gpr_InSel,
            RiCU   => gpr_RiCU,
            RiCDB  => gpr_RiCDB,
            Rx     => alu_rx,
            Ry     => alu_ry
          );
s : sr port map(
            clk    => clk,
            enable => sr_enable,
            reset  => sr_reset,
            Ri     => sr_input,
            Ro     => sr_Ro
            );
programcounter: pc port map(
            clk     => clk,
            enable  => pc_enable,
            reset   => pc_reset,
            Ri      => pc_Ri,
            Ro      => pc_Ro
          );
end cpu_arch;
