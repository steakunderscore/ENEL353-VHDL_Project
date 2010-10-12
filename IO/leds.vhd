----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:27:55 10/12/2010 
-- Design Name: 
-- Module Name:    led_io - Behavioral 
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY led_io IS
		PORT(
				data_add		: IN 			std_logic_vector(15 DOWNTO 0);  	-- address lines --
				data_data	: INOUT 		std_logic_vector(7 DOWNTO 0);  	-- data lines --
				data_read	: INOUT 		std_logic;								-- pulled high for read, low for write --
				data_req		: INOUT		std_logic;								-- pulled low to request bus usage --
				data_ack		: INOUT		std_logic;								-- pulled high to inform request completion --
				--
				clock 		: IN			std_logic;
				led_state	:OUT std_logic_vector(7 DOWNTO 0) --just to make diagram work!!!!!
				);
END led_io;

ARCHITECTURE led_arch OF led_io IS
		Signal led_enable		: std_logic;
--		Signal led_state		: std_logic_vector(7 DOWNTO 0);
BEGIN

   PROCESS(clock, data_req, data_add, data_read)
   BEGIN
			IF data_req = '0' AND data_add = "0000000000001110" AND data_read = '0' THEN
					led_enable <= '1';
			ELSE
					led_enable <= '0';
			END IF;
   END PROCESS;

    
	PROCESS(clock, led_enable) -- process of read data from the CPU and display LEDS
	BEGIN
			IF rising_edge(clock) THEN
				IF led_enable = '1' THEN
						led_state <= data_data;
						data_ack <= '0';
				END IF;           
			END IF;
	END PROCESS;



END led_arch;
				
