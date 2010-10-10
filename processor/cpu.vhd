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
use work.buses.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is

  PORT( --TODO: Change these to the actual port map
    --should be the busses and clk only
    clk            : IN std_logic);

end cpu;

architecture cpu_arch of cpu is
begin

    entity alu(alu_arch)
      port map(
        f
        rx
        ry
        ro
        Cin
        sr
      );
    entity ar(alu_arch)
      port map(
        clk => clk,
        enable
        read
        SelR
        Ri
        Ro
      );
    entity gpr(alu_arch)
      port map(
        clk => clk,
        enable
        SelRx
        SelRy
        SelRi
        Ri
        Rx
        Ry
      );
    entity spr(alu_arch)
      port map(
        clk => clk,
        enable
        read
        SelR
        Ri
        Ro
      );
end cpu_arch;
