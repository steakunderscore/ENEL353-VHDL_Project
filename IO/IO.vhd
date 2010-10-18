----------------------------------------------------------------------------------
-- Module Name:    IO
-- Description: Entity to hangle IO
-- Authors: Tracy Jackson
--          Sasha Wang
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
                data_add        : IN            std_logic_vector(15 DOWNTO 0);      -- address lines --
                data_data   : INOUT         std_logic_vector(7 DOWNTO 0);   -- data lines --
                data_read   : INOUT         std_logic;                              -- pulled high for read, low for write --
                data_req        : INOUT     std_logic;                              -- pulled low to request bus usage --
                data_ack        : INOUT     std_logic;                              -- pulled high to inform request completion --
                -- io --
                    clk         : IN            std_logic;
                    sw1         : IN            std_logic;
                    sw2         : IN            std_logic);
            --leds      : OUT std_logic_vector(7 DOWNTO 0);
end IO;

architecture io of IO is


COMPONENT led_io
    PORT(
            data_add        : IN            std_logic_vector(15 DOWNTO 0);      -- address lines --
            data_data   : INOUT         std_logic_vector(7 DOWNTO 0);   -- data lines --
            data_read   : INOUT         std_logic;                              -- pulled high for read, low for write --
            data_req        : INOUT     std_logic;                              -- pulled low to request bus usage --
            data_ack        : INOUT     std_logic;                              -- pulled high to inform request completion --

            clock       : IN            std_logic
            );
END COMPONENT;

COMPONENT switch_io IS
    PORT ( data_add         : IN            std_logic_vector(15 DOWNTO 0);
           data_data        : INOUT         std_logic_vector(7 DOWNTO 0);
           data_read        : INOUT         std_logic;
           data_req         : INOUT         std_logic;
           data_ack         : INOUT         std_logic;
           clk              : IN            std_logic;
           sw1              : IN            std_logic;
           sw2              : IN            std_logic
           );
END COMPONENT;



BEGIN

led: led_io PORT MAP(data_add, data_data, data_read, data_req, data_ack, clk);
switch: switch_io PORT MAP(data_add, data_data, data_read, data_req, data_ack, clk,sw1,sw2);

----------------------------------------------------------------------------------------------- 
     
END io;
