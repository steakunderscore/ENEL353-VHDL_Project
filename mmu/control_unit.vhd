library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.mmu_types.all;

entity mmu_control_unit is
  port (
     eoc          : in std_logic; -- High on muart has finished collecting data ??
     eot          : in std_logic; -- High on muart has finished transmitting data.
     ready        : in std_logic; -- ??
     data_read    : in std_logic; -- High if the data line is requesting a read, low for write.
     data_req     : in std_logic; -- Low when the data address is valid and should be read.
     data_add_0   : in std_logic; -- High for memory address, not IO.
     inst_req     : in std_logic; -- Low when the instruction address is valid and should be read.
     fr           : in std_logic; -- High if latest input headers fetch request was set.
     inst_or_data_in : in std_logic; -- High if latest input packet was an instruction packet.
     rw           : in std_logic; -- High if latest input packet had read/write set.
     write        : out std_logic; -- High to start muart writing data.
     inst_or_data_out : out std_logic; -- High if current output packet is an instruction packet.
     inst_ack     : out std_logic; -- Low when the inst is ready to be read by CPU. High otherwise.
     data_ack     : out std_logic; -- Low when the data is ready to be read by CPU. High impedance otherwise.
     muart_input  : out muart_input_state; -- State to multiplex the muart's input
     muart_output : out muart_output_state; -- State to multiplex the muart's output.
    clk    : in  std_logic
  );
end mmu_control_unit;

architecture mmu_control_unit_arch of mmu_control_unit is
  component data_control_unit is
    port (
     eoc          : in std_logic; -- High on muart has finished collecting data ??
     eot          : in std_logic; -- High on muart has finished transmitting data.
     ready        : in std_logic; -- ??
     data_read    : in std_logic; -- High if the data line is requesting a read, low for write.
     data_req     : in std_logic; -- Low when the data address is valid and should be read.
     data_add_0   : in std_logic; -- High for memory address, not IO.
     write        : out std_logic; -- High to start muart writing data.
     data_ack     : out std_logic; -- Low when the data is ready to be read by CPU. High impedance otherwise.
     muart_input  : out muart_input_state; -- State to multiplex the muart's input
     muart_output : out muart_output_state; -- State to multiplex the muart's output.
    clk    : in  std_logic
    );
  end component;
  
  component inst_control_unit is
    port (
     eoc          : in std_logic; -- High on muart has finished collecting data ??
     eot          : in std_logic; -- High on muart has finished transmitting data.
     ready        : in std_logic; -- ??
     inst_req     : in std_logic; -- Low when the instruction address is valid and should be read.
     write        : out std_logic; -- High to start muart writing data.
     inst_or_data : out std_logic; -- High if current output packet is an instruction packet.
     inst_ack     : out std_logic; -- Low when the inst is ready to be read by CPU. High otherwise.
     muart_input  : out muart_input_state; -- State to multiplex the muart's input
     muart_output : out muart_output_state; -- State to multiplex the muart's output.
    clk    : in  std_logic
    );
  end component;
  
  signal data_write, inst_write, inst_inst_or_data_out : std_logic;
  signal data_muart_input, inst_muart_input : muart_input_state;
  signal data_muart_output, inst_muart_output : muart_output_state;
begin
  data_cu : data_control_unit port map (eoc, eot, ready, data_read, data_req, data_add_0, data_write, data_ack, data_muart_input, data_muart_output, clk);
  inst_cu : inst_control_unit port map (eoc, eot, ready, inst_req, inst_write, inst_inst_or_data_out, inst_ack, inst_muart_input, inst_muart_output, clk);

  inst_or_data_out  <= inst_inst_or_data_out ;
  write <= inst_write or data_write;
  muart_input  <= inst_muart_input  when inst_inst_or_data_out = '1' else data_muart_input;
  muart_output <= inst_muart_output when inst_inst_or_data_out = '1' else data_muart_output;
end mmu_control_unit_arch;