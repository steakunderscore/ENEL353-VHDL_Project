--*************************************************************************
--*  Simple UART ip core                                                  *
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
--* useful, but without ANY WARRANTY; without even the implied            *
--* warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR               *
--* PURPOSE.  See the GNU Lesser General Public License for more          *
--* details.                                                              *
--*                                                                       *
--* You should have received a copy of the GNU Lesser General             *
--* Public License along with this source; if not, download it            *
--* from http://www.opencores.org/lgpl.shtml                              *
--*                                                                       *
--*************************************************************************
--*    To initialize the KS0070B/HD44780 display  send the following      *
--*    commands:    056-015-006-001-003 (decimal)                         *
--*************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity main is
  port (
    clk     : in  std_logic;
    txd     : out std_logic;
    rxd     : in  std_logic;        
    db      : out std_logic_vector (7 downto 0);
    segment : out std_logic_vector (7 downto 0);        
    inp     : in  std_logic_vector (7 downto 0);
    wr      : in  std_logic;        
    rs      : out std_logic;
    e       : out std_logic;
    led1    : out std_logic;
    led2_n  : out std_logic;
    led3_n  : out std_logic;
    switch  : in  std_logic
  );
end main;

architecture principaltst of main is
  component minimal_uart_core
    port( 
      clk   : in    std_logic;
      eoc   : out   std_logic;
      outp  : inout std_logic_vector(7 downto 0) := "zzzzzzzz";
      rxd   : in    std_logic;  
      txd   : out   std_logic;
      eot   : out   std_logic;
      inp   : in    std_logic_vector(7 downto 0);  
      ready : out   std_logic;
      wr    : in    std_logic    
    );
  end component;
  
  component decod 
    port (
      data    : in  std_logic_vector (7 downto 0);
      clk     : in  std_logic;
      segment : out std_logic_vector (7 downto 0);
      outp    : out std_logic_vector (7 downto 0);    
      eot     : in  std_logic;
      wr      : out std_logic        
    );
  end component;  
  
  signal eoc     : std_logic;
  signal rs_s    : std_logic := '1';
  signal eot     : std_logic;
  signal ready   : std_logic;
  signal wrt     : std_logic;
  signal dserial : std_logic_vector(7 downto 0) := x"00";
  signal inps    : std_logic_vector(7 downto 0) := x"00";
  signal edl     : std_logic := '0';
  
  begin
    muart : minimal_uart_core port map(clk, edl, dserial, rxd, txd, eot, inps, ready, wrt);
    test  : decod port map (dserial, clk, segment, inps, eot, wrt); 
    
    e <= edl;
    db <= dserial;
    eoc <= edl;
    --wrt<=wr; -- the decod component send data to the transmitter
    
    process (clk)
    begin  
      if (rising_edge(clk)) then
        if (edl = '1') then
          if (dserial = x"5c") then
            rs_s <= '0';
          elsif (dserial = x"5d") then
            rs_s <= '1';
          end if;
        end if;
      end if;
    end process;
    
    led1   <= rs_s;
    led2_n <= not(edl);
    led3_n <= '0';
    rs     <= rs_s;

  end principaltst;
