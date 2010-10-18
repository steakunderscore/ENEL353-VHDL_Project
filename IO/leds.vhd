----------------------------------------------------------------------------------
-- Module Name:    led_io
-- Description: Entity control output LEDs
-- Authors: Tracy Jackson
--          Sasha Wang
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;

ENTITY led_io IS
        PORT(
                data_add        : IN            std_logic_vector(15 DOWNTO 0);      -- address lines --
                data_data   : INOUT         std_logic_vector(7 DOWNTO 0);   -- data lines --
                data_read   : INOUT         std_logic;                              -- pulled high for read, low for write --
                data_req        : INOUT     std_logic;                              -- pulled low to request bus usage --
                data_ack        : INOUT     std_logic;                              -- pulled high to inform request completion --
                --
                clock       : IN            std_logic;
                );
END led_io;

ARCHITECTURE led_arch OF led_io IS
        Signal led_enable       : std_logic;
        Signal led_state        : std_logic_vector(7 DOWNTO 0);
BEGIN

   -- Determine if it is the LEDs being accessed
   PROCESS(clock, data_req, data_add, data_read)
   BEGIN
            IF data_req = '0' AND data_add = "0000000000001110" AND data_read = '0' THEN
                    led_enable <= '1';
            ELSE
                    led_enable <= '0';
            END IF;
   END PROCESS;

     -- process of data from the CPU and output to LEDS   
    PROCESS(clock, led_enable)
    BEGIN
            IF rising_edge(clock) THEN
                IF led_enable = '1' THEN
                        led_state <= data_data;
                        data_ack <= '0';
                END IF;           
            END IF;
    END PROCESS;



END led_arch;
                
