library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;

package mmu is
  type control_in_type is record
    eoc          : std_logic; -- High on muart has finished collecting data ??
    eot          : std_logic; -- High on muart has finished transmitting data.
    ready        : std_logic; -- ??
    data_read    : std_logic;
    data_req     : std_logic;
    data_add_0   : std_logic;
    inst_req     : std_logic;
    fr           : std_logic; -- High if latest input headers fetch request was set.
    inst_or_data : std_logic; -- High if latest input packet was an instruction packet.
  end record;

  type control_out_type is record
    write        : std_logic; -- High to start muart writing data.
    inst_or_data : std_logic; -- High if current output packet is an instruction packet.
    inst_ack     : std_logic;
    data_ack     : std_logic;
  end record;

  entity control_unit is
    port (
      input  : in  control_in_type;
      output : out control_out_type;
      clk    : in  std_logic;
    )
  end control_unit;

  architecture control_unit_arch of control_unit is
    type state is (idle, check_add, get_data, put_data, wait_clear);
    signal inst_state : state := idle;
    signal data_state : state := idle;

    inst_fsm : process(inst_state, input.inst_req, clk) begin
      if (rising_edge(clk)) then
        case inst_state is
          when idle =>
            if (input.inst_req = '0') then
              inst_state <= get_data;
            end if;
          
          when get_data =>
            -- get data;
            ouput.inst_ack <= '0';
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
      if (rising_edge(clk)
        case data_state is
          when idle =>
            if(input.data_req = '0') then
              data_state <= check_add;
            end if;

          when check_add =>
            if (input.data_req = '0' and input.data_add_0 = '1') then
              if input.data_read = '1' then
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
              output.data_ack <= 'z'
              data_state <= idle;
            end if;
        end case;
      end if;
    end process data_fsm;
  end control_unit_arch;
end mmu;
