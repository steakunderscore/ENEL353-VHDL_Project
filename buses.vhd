--	Package To Define The Bus Data Types
--
--	Purpose: This package is here to keep all the data types 
-- standard accross the whole project
--


library IEEE;
use IEEE.STD_LOGIC_1164.all;

package buses is

  
  type instruction is
    record
        opcode             : std_logic_vector( 5 downto 0);
		  operand            : std_logic_vector( 9 downto 0);
    end record;

-- Declare constants

  constant instructionLength  : integer := 16;
  constant opcodeLength       : integer := 6;
  constant operandLength      : integer := 10;
   
-- Declare functions and procedure

  --function <function_name>  (signal <signal_name> : in <type_ declaration>) return <type_declaration>;
  --procedure <procedure_name>	(<type_declaration> <constant_name>	: in <type_declaration>);

end buses;


package body buses is
  -- Is emtpy
end buses;
