----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:  18:59:20 09/18/2010 
-- Design Name: 
-- Module Name:  GPR - gpr_arch
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
use work.reg8;

entity gpr is
  Port (clk      : in   STD_LOGIC;
        enable   : in   STD_LOGIC;
        SelRx    : in   STD_LOGIC_VECTOR (2 downto 0);  -- The Rx output selection value
        SelRy    : in   STD_LOGIC_VECTOR (2 downto 0);  -- The Ry output selection value
        SelRi    : in   STD_LOGIC_VECTOR (2 downto 0);  -- The Ri input selection value
        Ri       : in   STD_LOGIC_VECTOR (7 downto 0);  -- The Ri input to GPR
        Rx       : out  STD_LOGIC_VECTOR (7 downto 0);  -- The Rx output
        Ry       : out  STD_LOGIC_VECTOR (7 downto 0)); -- The Ry output
end gpr;


architecture gpr_arch of gpr is
  component reg8 IS
    port(I      : in  std_logic_vector(7 downto 0);
         clock  : in  std_logic;
         enable : in  std_logic;
         Q      : out std_logic_vector(7 downto 0)
        );
  end component;

  signal  R0E  : std_logic;  -- Enable signals
  signal  R1E  : std_logic;
  signal  R2E  : std_logic;
  signal  R3E  : std_logic;
  signal  R4E  : std_logic;
  signal  R5E  : std_logic;
  signal  R6E  : std_logic;
  signal  R7E  : std_logic;
  signal  Q0   : std_logic_VECTOR (7 downto 0);
  signal  Q1   : std_logic_VECTOR (7 downto 0);
  signal  Q2   : std_logic_VECTOR (7 downto 0);
  signal  Q3   : std_logic_VECTOR (7 downto 0);
  signal  Q4   : std_logic_VECTOR (7 downto 0);
  signal  Q5   : std_logic_VECTOR (7 downto 0);
  signal  Q6   : std_logic_VECTOR (7 downto 0);
  signal  Q7   : std_logic_VECTOR (7 downto 0);
BEGIN
    reg_0 : reg8 port map(Ri, clk, R0E, Q0);
    reg_1 : reg8 port map(Ri, clk, R1E, Q1);
    reg_2 : reg8 port map(Ri, clk, R2E, Q2);
    reg_3 : reg8 port map(Ri, clk, R3E, Q3);
    reg_4 : reg8 port map(Ri, clk, R4E, Q4);
    reg_5 : reg8 port map(Ri, clk, R5E, Q5);
    reg_6 : reg8 port map(Ri, clk, R6E, Q6);
    reg_7 : reg8 port map(Ri, clk, R7E, Q7);

  -- Set Ri the input
  SetInput: process(clk, enable, SelRi)
  BEGIN
    R0E <= '0';
    R1E <= '0';
    R2E <= '0';
    R3E <= '0';
    R4E <= '0';
    R5E <= '0';
    R6E <= '0';
    R7E <= '0';
    case SelRi IS
      WHEN "000" =>
        R0E <= '1';
      WHEN "001" =>
        R1E <= '1';
      WHEN "010" =>
        R2E <= '1';
      WHEN "011" =>
        R3E <= '1';
      WHEN "100" =>
        R4E <= '1';
      WHEN "101" =>
        R5E <= '1';
      WHEN "110" =>
        R6E <= '1';
      WHEN "111" =>
        R7E <= '1';
      WHEN others =>
        NULL; -- None of them are enabled
    end case;
  end process;

  -- Set the Rx output
  WITH SelRx SELECT
  Rx <= Q0 WHEN "000",
        Q1 WHEN "001",
        Q2 WHEN "010",
        Q3 WHEN "011",
        Q4 WHEN "100",
        Q5 WHEN "101",
        Q6 WHEN "110",
        Q7 WHEN others;

-- Set the Ry output
  WITH SelRy SELECT
  Ry <= Q0 WHEN "000",
        Q1 WHEN "001",
        Q2 WHEN "010",
        Q3 WHEN "011",
        Q4 WHEN "100",
        Q5 WHEN "101",
        Q6 WHEN "110",
        Q7 WHEN others;

end gpr_arch;

