library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.mmu_control_types.data_in_type;
use work.mmu_control_types.data_out_type;
use work.mmu_control_types.muart_input_state;
use work.mmu_control_types.muart_output_state;

entity data_control_unit is
  port (
    input  : in  data_in_type;
    output : out data_out_type;
    clk    : in  std_logic
  );
end data_control_unit;

architecture data_control_unit_arch of data_control_unit is
  type state_type is (idle, get_data, put_data, wait_clear);
  type m_state_type is (idle,
                        set_header, set_add_high, set_add_low, set_data,
                        trans_header, trans_add_high, trans_add_low, trans_data,
                        get_header, get_data);
  signal state : state_type := idle;
  signal get_state, set_state : m_state_type := idle;
  signal transmitting : std_logic := '0';
begin
  data_fsm : process(state, input.data_req, clk) begin
    if (rising_edge(clk)) then
      case state is
        when idle =>
          if (input.data_req = '0' and input.data_add_0 = '1') then
            if input.data_read = '1' then
              state <= get_data;
            else
              state <= put_data;
            end if;
          else
            state <= idle;
          end if;
        
        when get_data =>
          -- get data;
          state <= wait_clear;
        
        when put_data =>
          -- put data
          state <= wait_clear;
        
        when wait_clear =>
          if (input.data_req = '1') then
            state <= idle;
          end if;
        
        when others =>
          state <= state;
      end case;
    end if;
  end process data_fsm;
  
  -- Outputs
  output.muart_input <= header         when (get_state = set_header   or set_state = set_header) else
                        data_add_high  when (get_state = set_add_high or set_state = set_add_high) else
                        data_add_low   when (get_state = set_add_low  or set_state = set_add_low)  else
                        data_data      when (set_state = set_data)    else
                        idle;
  output.muart_output <= header         when get_state = get_header or set_state = get_header else
                         data_data      when get_state = get_data   else
                         idle;
            
  with state select
    output.data_ack <= 'Z' when idle,
                       '1' when get_data | put_data,
                       '0' when wait_clear;
end data_control_unit_arch;
