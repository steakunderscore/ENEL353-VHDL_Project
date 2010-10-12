----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:  18:59:20 09/18/2010
-- Design Name: 
-- Module Name:  ar - Behavioral
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

library work;
use work.reg16;

entity ar is
  Port (clk      : in   STD_LOGIC;
        enable   : in   STD_LOGIC;
        SelRi    : in   STD_LOGIC_VECTOR (1 downto 0);   -- Select the address register
        SelRo    : in   STD_LOGIC_VECTOR (1 downto 0);   -- Select the address register
        Ri       : in   STD_LOGIC_VECTOR (15 downto 0);  -- The input
        Ro       : out  STD_LOGIC_VECTOR (15 downto 0)); -- The output
end ar;

architecture Behavioral of ar is
  component reg16 IS
    port(I      : in  std_logic_vector(15 downto 0);
         clock  : in  std_logic;
         enable : in  std_logic;
         Q      : out std_logic_vector(15 downto 0)
        );
  end component;
  
  signal  R0E  : std_logic;  -- Enable signals
  signal  R1E  : std_logic;
  signal  R2E  : std_logic;
  signal  Q0   : std_logic_VECTOR (15 downto 0);
  signal  Q1   : std_logic_VECTOR (15 downto 0);
  signal  Q2   : std_logic_VECTOR (15 downto 0);
BEGIN
    reg_0 : reg16 port map(Ri, clk, R0E, Q0);
    reg_1 : reg16 port map(Ri, clk, R1E, Q1);
    reg_2 : reg16 port map(Ri, clk, R2E, Q2);

  SetInput: process(clk, enable, SelRi, Ri)
  BEGIN
    R0E <= '0';
    R1E <= '0';
    R2E <= '0';
    IF enable = '1' THEN
      case SelRi IS
        WHEN "00" =>
          R0E <= '1';
        WHEN "01" =>
          R1E <= '1';
        WHEN "10" =>
          R2E <= '1';
        WHEN others =>
          NULL; -- None of them are enabled
      END CASE;
    END IF;
  end process;

  -- Set the output Ro
  WITH SelRo SELECT
  Ro <= Q0 WHEN "00",
        Q1 WHEN "01",
        Q2 WHEN others;
end Behavioral;

