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
--* useful, but WITHout ANY WARRANTY; without even the implied            *
--* warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR               *
--* PURPOSE.  See the GNU Lesser General Public License for more          *
--* details.                                                              *
--*                                                                       *
--* You should have received a copy of the GNU Lesser General             *
--* Public License along with this source; if not, download it            *
--* from http://www.opencores.org/lgpl.shtml                              *
--*                                                                       *
--*************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity minimal_uart_core is
  port(
    clock : in    std_logic;
    eoc   : out   std_logic;
    outp  : inout std_logic_vector(7 downto 0) := "ZZZZZZZZ";
    rxd   : in    std_logic;
    txd   : out   std_logic;
    eot   : out   std_logic;
    inp   : in    std_logic_vector(7 downto 0);
    ready : out   std_logic;
    wr    : in    std_logic
  );
end minimal_uart_core;

architecture principal of minimal_uart_core  is
  type state is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9);
  signal clk_serial       : std_logic := '0';
  signal start            : std_logic := '0';
  signal eocs, eoc1, eoc2 : std_logic := '0';
  signal rx_ck_enable     : std_logic := '0';
  signal receiving        : std_logic := '0';
  signal transmitting     : std_logic := '0';
  signal clk_txd          : std_logic := '0';
  signal txds             : std_logic := '1';
  signal eots             : std_logic := '0';
  signal inpl             : std_logic_vector(7 downto 0) := x"00";
  signal data             : std_logic_vector(7 downto 0) := x"00";
  signal atual_state, next_state, atual_state_txd, next_state_txd: state := s0;
  signal tx_enable        : std_logic := '0';
  signal tx_ck_enable     : std_logic := '0';

  component br_generator
    port (
      clock      : in  std_logic;
      rx_enable  : in  std_logic;
      clk_txd    : out std_logic;
      tx_enable  : in  std_logic;
      clk_serial : out std_logic
    );
  end component;

  begin
    ready <= not(tx_enable);
    brg : br_generator port map (clock, rx_ck_enable, clk_txd, tx_ck_enable, clk_serial);
    rx_ck_enable <= start or receiving;
    tx_ck_enable <= tx_enable or transmitting;

    start_detect : process(rxd, eocs)
    begin
      if (eocs = '1') then
        start <= '0';
      elsif (falling_edge(rxd)) then
        start <= '1';
      end if;
    end process start_detect;

    rxd_states : process (clk_serial)
    begin
      if (rising_edge(clk_serial)) then
        atual_state <= next_state;
      end if;
    end process rxd_states;

    rxd_state_machine : process(start, atual_state)
    begin
      if (start = '1' or receiving = '1') then
        case atual_state is
          when s0 =>
            eocs <= '0';
            if (start = '1') then
              next_state <= s1;
              receiving  <= '1';
            else
              next_state <= s0;
              receiving  <= '0';
            end if;
            
          when s1 =>
            receiving  <= '1';
            eocs       <= '0';
            next_state <= s2;
            
          when s2   =>
            receiving  <= '1';
            eocs       <= '0';
            next_state <= s3;
            
          when s3   =>
            receiving  <= '1';
            eocs       <= '0';
            next_state <= s4;
            
          when s4   =>
            receiving  <= '1';
            eocs       <= '0';
            next_state <= s5;
            
          when s5   =>
            receiving  <= '1';
            eocs       <= '0';
            next_state <= s6;
            
          when s6   =>
            receiving  <= '1';
            eocs       <= '0';
            next_state <= s7;
            
          when s7   =>
            receiving  <= '1';
            eocs       <= '0';
            next_state <= s8;
            
          when s8   =>
            receiving  <= '1';
            eocs       <= '0';
            next_state <= s9;
            
          when s9   =>
            receiving  <= '1';
            eocs       <= '1';
            next_state <= s0;
            
          when others =>
            null;
            
        end case;
      end if;
    end process rxd_state_machine;

    rxd_shift : process(clk_serial)
    begin
      if (rising_edge(clk_serial)) then
        if (eocs = '0') then
          data <= rxd & data(7 downto 1);
        end if;
      end if;
    end process rxd_shift;

    process (clock)
    begin
      if (rising_edge(clock)) then
        eoc <= eocs;
      end if;
    end process;

    process(atual_state)
    begin
      if (atual_state=s9) then
        outp <= data;
      end if;
    end process;

    txd_states : process(clk_txd)
    begin
      if (rising_edge(clk_txd)) then
        atual_state_txd <= next_state_txd;
      end if;
    end process txd_states;

    txd_state_machine : process(atual_state_txd, tx_enable)
    begin
      case atual_state_txd is
        when s0 =>
          inpl <= inp;
          eots <= '0';
          if (tx_enable = '1') then
            txds           <= '0';
            transmitting   <= '1';
            next_state_txd <= s1;
          else
            txds           <= '1';
            transmitting   <= '0';
            next_state_txd <= s0;
          end if;
          
        when s1 =>
          txds           <= inpl(0);
          eots           <= '0';
          transmitting   <= '1';
          next_state_txd <= s2;
          
        when s2 =>
          txds           <= inpl(1);
          eots           <= '0';
          transmitting   <= '1';
          next_state_txd <= s3;
          
        when s3 =>
          txds           <= inpl(2);
          eots           <= '0';
          transmitting   <= '1';
          next_state_txd <= s4;
          
        when s4 =>
          txds           <= inpl(3);
          eots           <= '0';
          transmitting   <= '1';
          next_state_txd <= s5;
          
        when s5 =>
          txds           <= inpl(4);
          eots           <= '0';
          transmitting   <= '1';
          next_state_txd <= s6;
          
        when s6 =>
          txds           <= inpl(5);
          eots           <= '0';
          transmitting   <= '1';
          next_state_txd <= s7;
          
        when s7 =>
          txds           <= inpl(6);
          eots           <= '0';
          transmitting   <= '1';
          next_state_txd <= s8;
          
        when s8 =>
          txds           <= inpl(7);
          eots           <= '0';
          transmitting   <= '1';
          next_state_txd <= s9;
          
        when s9 =>
          txds           <= '1';
          eots           <= '1';
          transmitting   <= '1';
          next_state_txd <= s0;
          
        when others =>
          null;
          
      end case;
    end process txd_state_machine;

    tx_start:process (clock, wr,  eots)
    begin
      if (eots = '1') then
        tx_enable <= '0';
      elsif (falling_edge(clock)) then
        if (wr = '1') then
          tx_enable <= '1';
        end if;
      end if;
    end process tx_start;

    eot<=eots;

    process (clock)
    begin
      if (rising_edge(clock)) then
        txd <= txds;
      end if;
    end process;

end principal ;