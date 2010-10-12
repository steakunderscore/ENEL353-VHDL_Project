----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:  18:59:20 09/18/2010
-- Design Name: 
-- Module Name:  spr - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: The Special Purpose Register is 3, 16bit registers. One for the PC,
-- another for the SR and the third is the IR.
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.std_logic_unsigned.all;


library work;
use work.reg16;

entity sr is
  Port (clk      : in  STD_LOGIC;
        enable   : in  STD_LOGIC;
        Ri       : in  STD_LOGIC_VECTOR (15 downto 0);  -- The input to the SR
        Ro       : out STD_LOGIC_VECTOR (15 downto 0)); -- The output from SR
end sr;


architecture sr_arch of sr is
  component reg16 IS
    port(I       : in  std_logic_vector(15 downto 0);
         clock   : in  std_logic;
         enable  : in  std_logic;
         Q       : out std_logic_vector(15 downto 0)
        );
  end component;
BEGIN
  reg_sr : reg16 port map(Ri, clk, enable, Ro);
end sr_arch;

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;





entity pc is
  Port (clk      : in  STD_LOGIC;
        enable   : in  STD_LOGIC;
        Ri       : in  STD_LOGIC_VECTOR (15 downto 0);  -- The input to the SR
        Ro       : out STD_LOGIC_VECTOR (15 downto 0)); -- The output from SR
end pc;


architecture pc_arch of pc is
  component reg16 IS
    port(I       : in  std_logic_vector(15 downto 0);
         clock   : in  std_logic;
         enable  : in  std_logic;
         Q       : out std_logic_vector(15 downto 0)
        );
  end component;
BEGIN
  reg_pc : reg16 port map(Ri, clk, enable, Ro);
end pc_arch;

