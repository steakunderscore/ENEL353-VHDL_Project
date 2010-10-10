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

entity decod is
  port (
    clock   : in  std_logic;
    eot     : in  std_logic;
    data    : in  std_logic_vector (7 downto 0);
    wr      : out std_logic;
    segment : out std_logic_vector (7 downto 0);
    outp    : out std_logic_vector (7 downto 0);
  );
end decod;

architecture behavioral of decod is
  signal clk_0_5   : std_logic := '0';
  signal clock_1   : std_logic := '0';
  signal hex       : std_logic_vector(3 downto 0)  := x"0";
  signal count_tst : std_logic_vector(7 downto 0)  := x"21";
  signal counter   : std_logic_vector(19 downto 0) := x"00000";
  signal countdv   : std_logic_vector(23 downto 0) := x"000000";

  begin
    segment(3) <= clk_0_5;
    wr <= clock_1;
    --wr<='0';
    clk_gen : process(clock)
    begin
      if (rising_edge(clock))   then
        if (countdv = x"0c3500")  then
         --if (countdv =x"000100")  then  --  uncomment to make simulations faster
          countdv <= x"000000";
          clock_1 <= not(clock_1);
        else
          countdv <= countdv + 1;
        end if;
      end if;
    end process;

    outp <= count_tst;

    process (clock_1)
    begin
      if (rising_edge(clock_1)) then
        count_tst <= count_tst + 1;
      end if;
      if (count_tst > x"7f")then
        count_tst <= x"21";
      end if;
    end process;

    process(clock_1)
    begin
      if (rising_edge(clock_1)) then
        if (counter = x"0003c") then
          counter <= x"00000";
          clk_0_5 <= not(clk_0_5);
        else
          counter <= counter + 1;
        end if;
      end if;
    end process ;

    with clk_0_5 select
      hex <= data(7 downto 4) when '0',
             data(3 downto 0) when others;

    with hex select  --123456789a=>
      segment <= "0001z100" when "0001",   --1
                 "1110z110" when "0010",   --2
                 "1011z110" when "0011",   --3
                 "1001z101" when "0100",   --4
                 "1011z011" when "0101",   --5
                 "1111z011" when "0110",   --6
                 "0001z110" when "0111",   --7
                 "1111z111" when "1000",   --8
                 "1001z111" when "1001",   --9
                 "1101z111" when "1010",   --a
                 "1111z001" when "1011",   --b
                 "1110z000" when "1100",   --c
                 "1111z100" when "1101",   --d
                 "1110z011" when "1110",   --e
                 "1100z011" when "1111",   --f
                 "0111z111" when others;   --0
end behavioral;


