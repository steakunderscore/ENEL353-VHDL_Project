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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IO is
       PORT(
            data_bus	: INOUT buses.data_bus;
		clk	: IN std_logic;
		sw1	: IN std_logic;
		sw2	: IN std_logic;
		leds	: OUT std_logic_vector(7 DOWNTO 0);
			
    );

end IO;

architecture Behavioral of IO is

signal data_data	: std_logic_vector(7 DOWNTO 0);
signal data_address	: std_logic_vector( 15 DOWNTO 0 );
signal read		: std_logic;
signal request		: std_logic;
signal ack		: std_logic;

BEGIN
	PROCESS(clk, data_bus, leds) -- process of read data from the CPU and display LEDS
	BEGIN
	IF rising_edge(clk) THEN
		IF request = '0' AND data_address(0) = '1' THEN
			CASE data_address IS
			  WHEN "0001" => leds(0) <= data_data(0);
			  WHEN "0011" => leds(1) <= data_data(1);
			  WHEN "0101" => leds(2) <= data_data(2);
			  WHEN "0111" => leds(3) <= data_data(3);
			  WHEN "1001" => leds(4) <= data_data(4);
			  WHEN "1011" => leds(5) <= data_data(5);
			  WHEN "1101" => leds(6) <= data_data(6);
			  WHEN "1111" => leds(7) <= data_data(7);
			  WHEN OTHERS => NULL;
			END CASE;
			data_bus.ack <= '0';
		END IF; -- do I need an ELSE clause to tell it to wait a cycle and detect again ???
			-- can the leds represented as std_logic_vectors ???
			-- have to have a flip-flop per led ? how are they represented ???
	END IF;
	END PROCESS;
	
	PROCESS(clk,data_bus, sw1, sw2)
	BEGIN
	IF rising_edge(clk) THEN
		read <= '0';
		IF sw1 = '1' AND request = '1' THEN
			data_bus.data = '01010101';
		ELSIF sw2 = '1' AND request = '1' THEN
			data_bus.data = '10101010';
		END IF;
		data_bus.ack <= '1';
	END IF;
	END PROCESS;			

END Behavioral;

