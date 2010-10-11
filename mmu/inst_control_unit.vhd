library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.mmu_control_types.inst_in_type;
use work.mmu_control_types.inst_out_type;
use work.mmu_control_types.muart_input_state;
use work.mmu_control_types.muart_output_state;

entity inst_control_unit is
  port (
    input  : in  inst_in_type;
    output : out inst_out_type;
    clk    : in  std_logic
  );
end inst_control_unit;

architecture inst_control_unit_arch of inst_control_unit is
  --type muart_input_state is (header, inst_add_high, inst_add_low, data_add_high, data_add_low, data_data, idle);
  --type muart_output_state is (header, inst_data_high, inst_data_low, data_data, idle);
  type state_type is (idle, get_data, wait_clear);
  type m_state_type is (idle,
                        set_header, set_add_high, set_add_low,
                        trans_header, trans_add_high, trans_add_low,
                        get_header, get_data_high, get_data_low);
  signal state : state_type := idle;
  signal get_state : m_state_type := idle;
  signal transmitting : std_logic := '0';
begin
  inst_fsm : process(state, input.inst_req, clk) begin
    if (rising_edge(clk)) then
      case state is
        when idle =>
          if (input.inst_req = '0') then
            state <= get_data;
          end if;
        
        when get_data =>
          -- get data;
          state <= wait_clear;
        
        when wait_clear =>
          if (input.inst_req = '1') then
            state <= idle;
          end if;
        
        when others =>
          state <= state;
      end case;
    end if;
  end process inst_fsm;
  
  get_inst_fsm : process(state, clk) begin
    if rising_edge(clk) then
      if state = get_data then
        case get_state is
          when idle =>
            get_state <= set_header;
          
          when set_header =>
            get_state <= trans_header;
          
          when trans_header =>
            if transmitting = '0' then
              output.write <= '1';
              transmitting <= '1';
            else
              output.write <= '0';
            end if;
            if transmitting = '1' and input.eot = '1' then
              transmitting <= '0';
              get_state <= set_add_low;
             end if;
           
          when set_add_low =>
            get_state <= trans_add_low;
          
          when trans_add_low =>
            if transmitting = '0' then
              output.write <= '1';
              transmitting <= '1';
            else
              output.write <= '0';
            end if;
            if transmitting = '1' and input.eot = '1' then
              transmitting <= '0';
              get_state <= set_add_high;
            end if;
           
          when set_add_high =>
            get_state <= trans_add_high;
          
          when trans_add_high =>
            if transmitting = '0' then
              output.write <= '1';
              transmitting <= '1';
            else
              output.write <= '0';
            end if;
            if transmitting = '1' and input.eot = '1' then
              transmitting <= '0';
              get_state <= idle;
            end if;
          when others =>
            NULL;
        end case;
      end if;
    end if;
  end process get_inst_fsm;
  
  -- Outputs
  with state select
    output.inst_ack <= '0' when wait_clear,
                       '1' when others;
  
  with state select
    output.inst_or_data <= '0' when idle,
                           '1' when others;
  
  with get_state select
    output.muart_input <= header         when set_header   | trans_header,
                          inst_add_high  when set_add_high | trans_add_high,
                          inst_add_low   when set_add_low  | trans_add_low,
                          idle           when others;
  
  with get_state select
    output.muart_output <= header         when get_header,
                           inst_data_high when get_data_high,
                           inst_data_low  when get_data_low,
                           idle           when others;
end inst_control_unit_arch;