library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package mmu_types is
   type muart_input_state is (header, inst_add_high, inst_add_low, data_add_high, data_add_low, data_data, idle);
   type muart_output_state is (header, inst_data_high, inst_data_low, data_data, idle);
  
   type control_in_type is record
     eoc          : std_logic; -- High on muart has finished collecting data ??
     eot          : std_logic; -- High on muart has finished transmitting data.
     ready        : std_logic; -- ??
     data_read    : std_logic; -- High if the data line is requesting a read, low for write.
     data_req     : std_logic; -- Low when the data address is valid and should be read.
     data_add_0   : std_logic; -- High for memory address, not IO.
     inst_req     : std_logic; -- Low when the instruction address is valid and should be read.
     fr           : std_logic; -- High if latest input headers fetch request was set.
     inst_or_data : std_logic; -- High if latest input packet was an instruction packet.
     rw           : std_logic; -- High if latest input packet had read/write set.
   end record;

   type control_out_type is record
     write        : std_logic; -- High to start muart writing data.
     inst_or_data : std_logic; -- High if current output packet is an instruction packet.
     inst_ack     : std_logic; -- Low when the inst is ready to be read by CPU. High otherwise.
     data_ack     : std_logic; -- Low when the data is ready to be read by CPU. High impedance otherwise.
     muart_input  : muart_input_state; -- State to multiplex the muart's input
     muart_output : muart_output_state; -- State to multiplex the muart's output.
   end record;
  
   type data_in_type is record
     eoc          : std_logic; -- High on muart has finished collecting data ??
     eot          : std_logic; -- High on muart has finished transmitting data.
     ready        : std_logic; -- ??
     data_read    : std_logic; -- High if the data line is requesting a read, low for write.
     data_req     : std_logic; -- Low when the data address is valid and should be read.
     data_add_0   : std_logic; -- High for memory address, not IO.
     fr           : std_logic; -- High if latest input headers fetch request was set.
     inst_or_data : std_logic; -- High if latest input packet was an instruction packet.
     rw           : std_logic; -- High if latest input packet had read/write set.
   end record;

   type data_out_type is record
     write        : std_logic; -- High to start muart writing data.
     inst_or_data : std_logic; -- High if current output packet is an instruction packet.
     data_ack     : std_logic; -- Low when the data is ready to be read by CPU. High impedance otherwise.
     muart_input  : muart_input_state; -- State to multiplex the muart's input
     muart_output : muart_output_state; -- State to multiplex the muart's output.
   end record;
  
   type inst_in_type is record
     eoc          : std_logic; -- High on muart has finished collecting data ??
     eot          : std_logic; -- High on muart has finished transmitting data.
     ready        : std_logic; -- ??
     inst_req     : std_logic; -- Low when the instruction address is valid and should be read.
     fr           : std_logic; -- High if latest input headers fetch request was set.
     inst_or_data : std_logic; -- High if latest input packet was an instruction packet.
     rw           : std_logic; -- High if latest input packet had read/write set.
   end record;

   type inst_out_type is record
     write        : std_logic; -- High to start muart writing data.
     inst_or_data : std_logic; -- High if current output packet is an instruction packet.
     inst_ack     : std_logic; -- Low when the inst is ready to be read by CPU. High otherwise.
     muart_input  : muart_input_state; -- State to multiplex the muart's input
     muart_output : muart_output_state; -- State to multiplex the muart's output.
   end record;
end mmu_types;
