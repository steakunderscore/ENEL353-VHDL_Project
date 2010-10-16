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
-- Revision: Saturday 16 Oct 2010 by Sasha
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.debounce;
use work.switch_reg;
use work.led_io;



---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IO is
       PORT(
				-- data bus --
				data_add		: IN 			std_logic_vector(15 DOWNTO 0);  	-- address lines --
				data_data	: INOUT 		std_logic_vector(7 DOWNTO 0);  	-- data lines --
				data_read	: INOUT 		std_logic;								-- pulled high for read, low for write --
				data_req		: INOUT		std_logic;								-- pulled low to request bus usage --
				data_ack		: INOUT		std_logic;								-- pulled high to inform request completion --
				-- io --
            clk         : IN 			std_logic;
            sw1         : IN 			std_logic;
            sw2         : IN 			std_logic);
            --leds      : OUT std_logic_vector(7 DOWNTO 0);
end IO;

architecture Behavioral of IO is


signal led_state    			: std_logic_vector(7 DOWNTO 0);
signal enable1      			: std_logic;
signal switch1_connection 	: std_logic;
signal switch1_output 		: std_logic;
--signal switch1_state 		: std_logic;

signal enable2      			: std_logic;
signal switch2_connection 	: std_logic;
signal switch2_output 		: std_logic;
--signal switch2_state 		: std_logic;


COMPONENT debounce
		 PORT(clk, switch : IN STD_LOGIC;
				switch_state: OUT STD_LOGIC);
END COMPONENT;

COMPONENT switch_reg
		 PORT( D 			: IN STD_LOGIC;
				clk, enable	: IN STD_LOGIC;
				Q 				: OUT STD_LOGIC);
END COMPONENT;


COMPONENT led_io
	PORT(
			data_add		: IN 			std_logic_vector(15 DOWNTO 0);  	-- address lines --
			data_data	: INOUT 		std_logic_vector(7 DOWNTO 0);  	-- data lines --
			data_read	: INOUT 		std_logic;								-- pulled high for read, low for write --
			data_req		: INOUT		std_logic;								-- pulled low to request bus usage --
			data_ack		: INOUT		std_logic;								-- pulled high to inform request completion --

			clock 		: IN			std_logic
			);
END COMPONENT;



BEGIN

sw1_debouncer: debounce PORT MAP(clk, sw1, switch1_connection);
sw1_status: switch_reg PORT MAP(switch1_connection,clk, enable1, switch1_output); --!! reset --


sw2_debouncer: debounce PORT MAP(clk, sw2,switch2_connection);
sw2_status: switch_reg PORT MAP(switch2_connection,clk, enable2, switch2_output); --!! reset --



PROCESS(switch1_output,switch2_output, data_ack)
BEGIN
IF rising_edge(clk) THEN
	IF switch1_output = '1' AND data_ack = 'Z' THEN --when the switch_reg has stored 1, disable switch_reg from getting any more info
		enable1 <= '0';
	
	--ELSIF data_ack = '0' AND data_add = "0000000000001110" THEN -- when the data is sent to the CPU, enable the switch_reg again
	--	enable1 <= '1';
	ELSE
		enable1 <= '1';
	END IF;
	
	IF switch2_output = '1' AND data_ack = 'Z' THEN --when the switch_reg has stored 1, disable switch_reg from getting any more info
		enable2 <= '0';
	
	--ELSIF data_ack = '0' AND data_add = "0000000000001100" THEN -- when the data is sent to the CPU, enable the switch_reg again
	--	enable2 <= '1';
	ELSE
		enable2 <= '1';
	END IF;
	
	
END IF;
END PROCESS;







PROCESS(clk, data_add, data_read)
BEGIN
	IF rising_edge(clk) THEN
		IF data_req = '0' AND data_read = '1' THEN
			IF data_add = "0000000000001110" THEN -- switch1 address
				IF switch1_output = '1' THEN
					data_data <= "00000001";
				ELSE
					data_data <= "00000000";
				END IF;
				data_ack <= '0';
			END IF;
			IF data_add = "0000000000001100" THEN -- switch2 address
				IF switch2_output = '1' THEN
					data_data <= "00000001";
				ELSE
					data_data <= "00000000";
				END IF;
				data_ack <= '0';
			END IF;
		ELSIF data_req = '1' AND data_ack = '0' THEN
			data_ack <= 'Z';
		END IF;
	END IF;
 END PROCESS;



--led: led_io PORT MAP(data_add, data_data, data_read, data_req, data_ack, clk);

----------------------------------------------------------------------------------------------- 
	 
END Behavioral;