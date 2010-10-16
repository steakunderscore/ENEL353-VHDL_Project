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

	signal led_state    				: std_logic_vector(7 DOWNTO 0);
	signal enable       				: std_logic;
	signal switch1_connection 		: std_logic;
	signal switch1_output 			: std_logic;
	signal switch1_state 			: std_logic;

	COMPONENT debounce
          PORT(clk, switch : IN STD_LOGIC;
          switch_state: OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT switch_reg
          PORT( D : IN STD_LOGIC;
          reset, clk : IN STD_LOGIC;
          Q : OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT led_io
		PORT(
				data_add		: IN 			std_logic_vector(15 DOWNTO 0);  	-- address lines --
				data_data	: INOUT 		std_logic_vector(7 DOWNTO 0);  	-- data lines --
				data_read	: INOUT 		std_logic;								-- pulled high for read, low for write --
				data_req		: INOUT		std_logic;								-- pulled low to request bus usage --
				data_ack		: INOUT		std_logic;								-- pulled high to inform request completion --
				--
				clock 		: IN			std_logic
				);
	END COMPONENT;


BEGIN
sw1_status: switch_reg PORT MAP(switch1_state,clk, clk, switch1_output); --!! reset --
sw1_debouncer: debounce PORT MAP(clk, sw1,switch1_connection);

led: led_io PORT MAP(data_add, data_data, data_read, data_req, data_ack, clk);

 
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
 PROCESS(clk, data_read)
 BEGIN
      IF rising_edge(clk) THEN
         IF data_read = '1' THEN
            IF data_add = "0000000000000010" THEN
               data_data <= "11111111";
            ELSIF data_add = "0000000000000100" THEN
               -- send button 2 status

            END IF;
         END IF;
      END IF;
 END PROCESS;


END Behavioral;

