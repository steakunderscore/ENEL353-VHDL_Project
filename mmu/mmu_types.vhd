library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package mmu_types is
   type muart_input_state is (header, inst_add_high, inst_add_low, data_add_high, data_add_low, data_data, idle);
   type muart_output_state is (header, inst_data_high, inst_data_low, data_data, clear_data, idle);
end mmu_types;
