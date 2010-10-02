--  Package To Define The Bus Data Types
--
--  Purpose: This package is here to keep all the data types 
-- standard accross the whole project
--


library IEEE;
use IEEE.STD_LOGIC_1164.all;

package buses is
  type inst_bus is
    record
      add  : std_logic_vector(11 downto 0); -- Address lines.
      data : std_logic_vector(15 downto 0); -- Data lines.
      req  : std_logic;                     -- Pulled low to request bus usage.
      ack  : std_logic;                     -- Pulled high to inform of request completion.
    end record;


  type data_bus is
    record
      add  : std_logic_vector(15 downto 0); -- Address lines.
      data : std_logic_vector(7 downto 0);  -- Data lines.
      red  : std_logic;                     -- High for a read request, low for a write request.
      req  : std_logic;                     -- Pulled low to request bus usage.
      ack  : std_logic;                     -- Pulled high to inform of request completion.
    end record;
end buses;


package body buses is
-- Is empty
  end buses;
