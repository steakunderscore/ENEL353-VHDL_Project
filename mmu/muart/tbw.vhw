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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use std.textio.all;

entity tbw is
end tbw;

architecture testbench_arch of tbw is
  component minimal_uart_core
    port (
      clock : in    std_logic;
      eoc   : out   std_logic;
      outp  : inout std_logic_vector (7 downto 0);
      rxd   : in    std_logic;
      txd   : out   std_logic;
      eot   : out   std_logic;
      inp   : in    std_logic_vector (7 downto 0);
      ready : out   std_logic;
      wr    : in    std_logic
    );
  end component;

  signal clock : std_logic := '0';
  signal eoc : std_logic := '0';
  signal outp : std_logic_vector (7 downto 0) := "zzzzzzzz";
  signal rxd : std_logic := '1';
  signal txd : std_logic := '0';
  signal eot : std_logic := '0';
  signal inp : std_logic_vector (7 downto 0) := "00000000";
  signal ready : std_logic := '0';
  signal wr : std_logic := '0';

  constant period : time := 26 ns;
  constant duty_cycle : real := 0.5;
  constant offset : time := 0 ns;

  begin
    uut : minimal_uart_core
    port map (
        clock => clock,
        eoc => eoc,
        outp => outp,
        rxd => rxd,
        txd => txd,
        eot => eot,
        inp => inp,
        ready => ready,
        wr => wr
    );

    process    -- clock process for clock
    begin
      wait for offset;
      clock_loop : loop
        clock <= '0';
        wait for (period - (period * duty_cycle));
        clock <= '1';
        wait for (period * duty_cycle);
      end loop clock_loop;
    end process;

    process
    begin
      -- -------------  current time:  8562ns
      wait for 8562 ns;
      rxd <= '0';
      -- -------------------------------------
      -- -------------  current time:  18728ns
      wait for 10166 ns;
      rxd <= '1';
      -- -------------------------------------
      -- -------------  current time:  26814ns
      wait for 8086 ns;
      inp <= "10100110";
      -- -------------------------------------
      -- -------------  current time:  27776ns
      wait for 962 ns;
      rxd <= '0';
      -- -------------------------------------
      -- -------------  current time:  34744ns
      wait for 6968 ns;
      wr <= '1';
      -- -------------------------------------
      -- -------------  current time:  35342ns
      wait for 598 ns;
      wr <= '0';
      -- -------------------------------------
      -- -------------  current time:  36304ns
      wait for 962 ns;
      rxd <= '1';
      -- -------------------------------------
      -- -------------  current time:  45482ns
      wait for 9178 ns;
      rxd <= '0';
      -- -------------------------------------
      -- -------------  current time:  54244ns
      wait for 8762 ns;
      rxd <= '1';
      -- -------------------------------------
      -- -------------  current time:  62590ns
      wait for 8346 ns;
      rxd <= '0';
      -- -------------------------------------
      -- -------------  current time:  72340ns
      wait for 9750 ns;
      rxd <= '1';
      -- -------------------------------------
      -- -------------  current time:  80842ns
      wait for 8502 ns;
      rxd <= '0';
      -- -------------------------------------
      -- -------------  current time:  90280ns
      wait for 9438 ns;
      rxd <= '1';
      -- -------------------------------------
      -- -------------  current time:  200598ns
      wait for 110318 ns;
      inp <= "01011101";
      -- -------------------------------------
      -- -------------  current time:  205096ns
      wait for 4498 ns;
      rxd <= '0';
      -- -------------------------------------
      -- -------------  current time:  206084ns
      wait for 988 ns;
      wr <= '1';
      -- -------------------------------------
      -- -------------  current time:  207306ns
      wait for 1222 ns;
      wr <= '0';
      -- -------------------------------------
      -- -------------  current time:  214040ns
      wait for 6734 ns;
      rxd <= '1';
      -- -------------------------------------
      -- -------------  current time:  346926ns
      wait for 132886 ns;
      inp <= "10000011";
      -- -------------------------------------
      -- -------------  current time:  352438ns
      wait for 5512 ns;
      wr <= '1';
      -- -------------------------------------
      -- -------------  current time:  353036ns
      wait for 598 ns;
      wr <= '0';
      -- -------------------------------------
      wait for 146990 ns;
    end process;

end testbench_arch;

