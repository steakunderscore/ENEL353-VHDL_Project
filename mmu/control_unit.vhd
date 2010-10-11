library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package mmu_control_types is
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
	 rw				: std_logic;
  end record;

  type control_out_type is record
    write        : std_logic; -- High to start muart writing data.
    inst_or_data : std_logic; -- High if current output packet is an instruction packet.
    inst_ack     : std_logic; -- Low when the inst is ready to be read by CPU. High otherwise.
    data_ack     : std_logic; -- Low when the data is ready to be read by CPU. High impedance otherwise.
  end record;
end mmu_control_types;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.mmu_control_types.control_in_type;
use work.mmu_control_types.control_out_type;

  entity mmu_control_unit is
    port (
      input  : in  control_in_type;
      output : out control_out_type;
      clk    : in  std_logic
    );
  end mmu_control_unit;

  architecture mmu_control_unit_arch of mmu_control_unit is
    type state is (idle, get_data, put_data, wait_clear);
    signal inst_state : state := idle;
    signal data_state : state := idle;
  begin
    inst_fsm : process(inst_state, input.inst_req, clk) begin
      if (rising_edge(clk)) then
        case inst_state is
          when idle =>
            if (input.inst_req = '0') then
              inst_state <= get_data;
            end if;
          
          when get_data =>
            -- get data;
            output.inst_ack <= '0';
            inst_state <= wait_clear;
          
          when wait_clear =>
            if (input.inst_req = '1') then
              output.inst_ack <= '1';
              inst_state <= idle;
            end if;
          
          when others =>
            inst_state <= inst_state;
          
        end case;
      end if;
    end process inst_fsm;
    
    data_fsm : process(data_state, input.data_req, clk) begin
      if (rising_edge(clk)) then
        case data_state is
          when idle =>
            if (input.data_req = '0' and input.data_add_0 = '1') then
              if input.data_read = '1' then
				    output.data_ack <= '1';
                data_state <= get_data;
              else
                data_state <= put_data;
              end if;
            else
              data_state <= idle;
            end if;
          
          when get_data =>
            -- get data;
            output.data_ack <= '0';
            data_state <= wait_clear;
          
          when put_data =>
            -- put data
            output.data_ack <= '0';
            data_state <= wait_clear;
          
          when wait_clear =>
            if (input.data_req = '1') then
              output.data_ack <= 'Z';
              data_state <= idle;
            end if;
        end case;
      end if;
    end process data_fsm;
  end mmu_control_unit_arch;