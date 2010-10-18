-- Authors:
--      Wim Looman, Forrest McKerchar

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.mmu_types.all;

entity mmu_control_unit is
  port (
     eoc              : in  std_logic; -- High on muart has finished collecting data
     eot              : in  std_logic; -- High on muart has finished transmitting
     ready            : in  std_logic; -- High if the muart is ready for new transfer
     data_read        : in  std_logic; -- High if the cpu requests a read, else write
     data_req         : in  std_logic; -- Low to start a transfer
     data_add_0       : in  std_logic; -- High for memory address, else IO
     inst_req         : in  std_logic; -- Low to start a transfer
     fr               : in  std_logic; -- Input headers fetch request bit
     inst_or_data_in  : in  std_logic; -- Input headers inst or data bit
     rw               : in  std_logic; -- Input headers read/!write bit
     write            : out std_logic; -- Pulled high to start muart writing data
     inst_or_data_out : out std_logic; -- Ouput headers inst or data bit
     inst_ack         : out std_logic; -- Idles high, pulled low when data ready
     data_ack         : inout std_logic; -- Idles 'Z', high when data not ready, pulled low when data ready
     muart_input      : out muart_input_state; -- Signal connected to muart input
     muart_output     : out muart_output_state; -- Signal connected to muart output
     clk              : in  std_logic
  );
end mmu_control_unit;

architecture mmu_control_unit_arch of mmu_control_unit is
  component data_control_unit is
    port (
     eoc          : in  std_logic; -- High on muart has finished collecting data
     eot          : in  std_logic; -- High on muart has finished transmitting
     ready        : in  std_logic; -- High if the muart is ready for new transfer
     data_read    : in  std_logic; -- High if the cpu requests a read, else write
     data_req     : in  std_logic; -- Low to start a transfer
     data_add_0   : in  std_logic; -- High for memory address, else IO
     write        : out std_logic; -- Pulled high to start muart writing data.
     data_ack     : inout std_logic; -- Idles 'Z', high when data not ready, pulled low when data ready
     muart_input  : out muart_input_state; -- Signal connected to muart input
     muart_output : out muart_output_state; -- Signal connected to muart output
     clk          : in  std_logic
    );
  end component;
  
  component inst_control_unit is
    port (
     eoc          : in  std_logic; -- High on muart has finished collecting data
     eot          : in  std_logic; -- High on muart has finished transmitting
     ready        : in  std_logic; -- High if the muart is ready for new transfer
     inst_req     : in  std_logic; -- Low to start a transfer
     write        : out std_logic; -- Pulled high to start muart writing data
     inst_or_data : out std_logic; -- Ouput headers inst or data bit
     inst_ack     : out std_logic; -- Idles high, pulled low when data ready
     muart_input  : out muart_input_state; -- Signal connected to muart input
     muart_output : out muart_output_state; -- Signal connected to muart output
     clk          : in  std_logic
    );
  end component;
  
  signal data_write, inst_write, inst_inst_or_data_out : std_logic;
  signal data_muart_input, inst_muart_input : muart_input_state;
  signal data_muart_output, inst_muart_output : muart_output_state;
begin
  data_cu : data_control_unit port map (
    eoc,
    eot,
    ready,
    data_read,
    data_req,
    data_add_0,
    data_write,
    data_ack,
    data_muart_input,
    data_muart_output,
    clk
  );
  inst_cu : inst_control_unit port map (
    eoc,
    eot,
    ready,
    inst_req,
    inst_write,
    inst_inst_or_data_out,
    inst_ack,
    inst_muart_input,
    inst_muart_output,
    clk
  );

  inst_or_data_out <= inst_inst_or_data_out ;
  write            <= inst_write or data_write;
  muart_input  <= inst_muart_input  when inst_inst_or_data_out = '1' else
                  data_muart_input;
  muart_output <= inst_muart_output when inst_inst_or_data_out = '1' else
                  data_muart_output;
end mmu_control_unit_arch;