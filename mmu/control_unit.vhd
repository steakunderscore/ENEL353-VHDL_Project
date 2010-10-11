library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package mmu_control_types is
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
end mmu_control_types;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.mmu_control_types.control_in_type;
use work.mmu_control_types.control_out_type;
use work.mmu_control_types.data_in_type;
use work.mmu_control_types.data_out_type;
use work.mmu_control_types.inst_in_type;
use work.mmu_control_types.inst_out_type;
use work.mmu_control_types.muart_input_state;
use work.mmu_control_types.muart_output_state;

entity mmu_control_unit is
  port (
    input  : in  control_in_type;
    output : out control_out_type;
    clk    : in  std_logic
  );
end mmu_control_unit;

architecture mmu_control_unit_arch of mmu_control_unit is
  signal data_in  : data_in_type;
  signal data_out : data_out_type;
  signal inst_in  : inst_in_type;
  signal inst_out : inst_out_type;
  
  component data_control_unit is
    port (
      input  : in  data_in_type;
      output : out data_out_type;
      clk    : in  std_logic
    );
  end component;
  
  component inst_control_unit is
    port (
      input  : in  inst_in_type;
      output : out inst_out_type;
      clk    : in  std_logic
    );
  end component;
begin

    inst_in.eoc          <= input.eoc;
    inst_in.eot          <= input.eot;
    inst_in.ready        <= input.ready;
    inst_in.inst_req     <= input.inst_req;
    inst_in.fr           <= input.fr;
    inst_in.inst_or_data <= input.inst_or_data;
    inst_in.rw           <= input.rw;


    output.write <= inst_out.write;
    output.inst_or_data <= inst_out.inst_or_data;
    output.inst_ack <= inst_out.inst_ack;
    output.muart_input <= inst_out.muart_input;
    output.muart_output <= inst_out.muart_output;
    
  --data_cu : data_control_unit port map (data_in, data_out, clk);
  inst_cu : inst_control_unit port map (inst_in, inst_out, clk);
end mmu_control_unit_arch;