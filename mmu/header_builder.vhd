-- Author:
--      Forrest McKerchar

-- builds a header to feed into the RS-232 link

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;

entity header_builder is
  port (
    read_write : in  std_logic; -- 1 = read, 0 = write
    inst_data  : in  std_logic; -- 1 = inst, 0 = data
    header     : out std_logic_vector(7 downto 0)
  );
end header_builder;

architecture header_builder_arch of header_builder is
begin
  header(7) <= read_write or inst_data; -- reading from or writing to
                                             -- memory? (can't write
                                             -- instructions)
  header(6) <= '0'; -- reserved
  header(5) <= '0'; -- reserved
  header(4) <= '0'; -- reserved
  header(3) <= '0'; -- diagnostic
  header(2) <= '0'; -- diagnostic;
  header(1) <= '0'; --  1 if data is being retrieved from RS-232 link
  header(0) <= inst_data; -- instruction data or data data?
end header_builder_arch;

