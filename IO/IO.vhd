----------------------------------------------------------------------------------
-- Company: 
-- Engineer:
-- 
-- Create Date:    16:08:33 09/15/2010
-- Design Name:
-- Module Name:    IO - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.buses.ALL;
use work.debounce;
use work.switch_reg;



---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IO is
       PORT(
            data_bus    : INOUT buses.data_bus;
            clk         : IN std_logic;
            sw1         : IN std_logic;
            sw2         : IN std_logic);
            --leds      : OUT std_logic_vector(7 DOWNTO 0);
end IO;

architecture Behavioral of IO is

signal led_state    : std_logic_vector(7 DOWNTO 0);
signal enable       : std_logic;
signal switch1_connection : std_logic;
signal switch1_output : std_logic;

COMPONENT debounce
          PORT(clk, switch : IN STD_LOGIC;
          switch_state: OUT STD_LOGIC);
END COMPONENT;

COMPONENT switch_reg
          PORT( D : IN STD_LOGIC;
          reset, clk : IN STD_LOGIC;
          Q : OUT STD_LOGIC);
END COMPONENT;

BEGIN
sw1_status: switch_reg PORT MAP(switch1_connection,clk, clk, switch1_output); --!! reset --
sw1_debouncer: debounce PORT MAP(clk, sw1,switch1_connection);
     PROCESS(clk, data_bus)
     BEGIN
     IF data_bus.req = '0' AND data_bus.add = '0000000000001110' AND data_bus.red = '0' THEN
        enable <= '1';
     ELSE
         enable <= '0';
     END IF
     END PROCESS;

    PROCESS(clk, data_bus, leds) -- process of read data from the CPU and display LEDS
    BEGIN
    IF rising_edge(clk) THEN
       IF enable = '1' THEN
            led_state <= data_bus.data;
            data_bus.ack <= '0';
        END IF; -- do I need an ELSE clause to tell it to wait a cycle and detect again ???
            -- have to have a flip-flop per led ? how are they represented ???
    END IF;
    END PROCESS;
-----------------------------------------------------------------------------------------------
--Check the buttons status
-- PROCESS(clk,data_bus, sw1, sw2)
 --   BEGIN
 --   IF rising_edge(clk) THEN
 --       IF sw1 = '1'  THEN
 --         -- store switch 1 status
  --      ELSIF sw2 = '1' THEN
 --         -- store switch 2 status
 --       END IF;

 --   END IF;
 --   END PROCESS;

 -- Checks for cpu request on button
 PROCESS(clk, data_bus)
 BEGIN
      IF rising_edge(clk) THEN
         IF data_bus.red = '1' THEN
            IF data_bus.add = '0000000000000010' THEN
               data_bus.data <= switch1_output;
            ELSIF data_bus.add = '0000000000000100' THEN
               -- send button 2 status

            END IF;
         END IF;
      END IF;
 END PROCESS;


END Behavioral;

