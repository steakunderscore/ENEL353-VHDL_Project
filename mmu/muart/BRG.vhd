--*************************************************************************
--*  Minimal UART ip core                                                 *
--* Author: Arao Hayashida Filho        arao@medinovacao.com.br           *
--*                                                                       *
--*************************************************************************
--*                                                                       *
--* Copyright (C) 2009 Arao Hayashida Filho                               *
--*                                                                       *
--* This source file may be used and distributed without                  *
--* restriction provided that this copyright statement is not             *
--* removed from the file and that any derivative work contains           *
--* the original copyright notice and the associated disclaimer.          *
--*                                                                       *
--* This source file is free software; you can redistribute it            *
--* and/or modify it under the terms of the GNU Lesser General            *
--* Public License as published by the Free Software Foundation;          *
--* either version 2.1 of the License, or (at your option) any            *
--* later version.                                                        *
--*                                                                       *
--* This source is distributed in the hope that it will be                *
--* useful, but WITHOUT ANY WARRANTY; without even the implied            *
--* warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR               *
--* PURPOSE.  See the GNU Lesser General Public License for more          *
--* details.                                                              *
--*                                                                       *
--* You should have received a copy of the GNU Lesser General             *
--* Public License along with this source; if not, download it            *
--* from http://www.opencores.org/lgpl.shtml                              *
--*                                                                       *
--*************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity br_generator is
  generic (divider_width: integer := 16);
  port (
    clock      : in  std_logic;
    rx_enable  : in  std_logic;
    clk_txd    : out std_logic;
    tx_enable  : in  std_logic;
    clk_serial : out std_logic
  );
end br_generator;

architecture principal of br_generator is
  -- change the following constant to your desired baud rate
  -- one hz equal to one bit per second
  signal   count_brg     : std_logic_vector(divider_width - 1 downto 0) := (others => '0');
  signal   count_brg_txd : std_logic_vector(divider_width - 1 downto 0) := (others => '0');
  constant brdvd         : std_logic_vector(divider_width - 1 downto 0) := x"0516"; -- 38400 bps @ 50MHz

  begin
    txd : process (clock)
    begin
      if (rising_edge(clock)) then
        if (count_brg_txd = brdvd) then
          clk_txd       <= '1';
          count_brg_txd <= (others => '0');
        elsif (tx_enable = '1') then
          clk_txd       <= '0';
          count_brg_txd <= count_brg_txd + 1;
        else
          clk_txd       <= '0';
          count_brg_txd <= (others => '0');
        end if;
      end if;
    end process txd;

    rxd : process (clock)
    begin
      if (rising_edge(clock)) then
        if (count_brg=brdvd) then
          count_brg  <= (others => '0');
          clk_serial <= '1';
        elsif (rx_enable = '1') then
          count_brg  <= count_brg+1;
          clk_serial <= '0';
        else
          count_brg  <= '0' & brdvd(divider_width - 1 downto 1);
          clk_serial <= '0';
        end if;
      end if;
    end process rxd;
end principal;
