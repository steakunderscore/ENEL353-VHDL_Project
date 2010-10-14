-- decodes a header received from the RS-232 link

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;

entity header_decoder is
  port (
    read_write    : out  std_logic; -- 1 = read, 0 = write
    fetch_request : out std_logic;
    inst_data     : out  std_logic; -- 1 = inst, 0 = data
    header        : in std_logic_vector(7 downto 0)
  );
end header_decoder;

architecture header_decoder_arch of header_decoder is
begin
  read_write <= header(7); -- reading or writing? (should be 1 in this case)
  fetch_request <= header(1); -- fetch request? (should be 1n this case)
  inst_data <= header(0); -- instruction data or data data?
end header_decoder_arch;

