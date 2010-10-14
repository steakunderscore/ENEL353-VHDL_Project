library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.mmu_types.all;

entity data_control_unit is
  port (
    input  : in  data_in_type;
    output : out data_out_type;
    clk    : in  std_logic
  );
end data_control_unit;

architecture data_control_unit_arch of data_control_unit is
  type state_type is (idle, get_data, wait_clear);
  type m_state_type is (idle,
                        send_header, send_add_high, send_add_low, send_data,
                        get_header,  get_add_high,  get_add_low,  get_data,
                        finished);
  type read_state_type is (idle, wait_data, read_data, pause, finished);
  type transmit_state_type is (idle, set_data, trans_data, pause, finished);
  signal state : state_type := idle;
  signal get_state : m_state_type := idle;
  signal reader_state : read_state_type := idle;
  signal transmitter_state : transmit_state_type := idle;
begin
  data_fsm : process(state, input.data_req, clk) begin
    if (rising_edge(clk)) then
      case state is
        when idle =>
          if (input.data_req = '0' and input.data_add_0 = '1') then
            state <= get_data;
          end if;
        
        when get_data =>
          if (get_state = finished) then
            state <= wait_clear;
          end if;
        
        when wait_clear =>
          if (input.data_req = '1') then
            state <= idle;
          end if;
        
        when others =>
          NULL;
      end case;
    end if;
  end process data_fsm;
  
  get_data_fsm : process(state, clk) begin
    if rising_edge(clk) then
      if state = get_data then
        case get_state is
          when idle =>
            get_state <= send_header;
          
          when send_header =>
            if transmitter_state = finished then
              get_state <= send_add_low;
            end if;
          
          when send_add_low =>
            if transmitter_state = finished then
              get_state <= send_add_high;
            end if;
          
          when send_add_high =>
            if transmitter_state = finished then
              if input.data_read = '1' then
                get_state <= get_header;
              else
                get_state <= send_data;
              end if;
            end if;
          
          when send_data =>
            if transmitter_state = finished then
              get_state <= finished;
            end if;
          
          when get_header =>
            if reader_state = finished then
              get_state <= get_add_low;
            end if;
            
          when get_add_low =>
            if reader_state = finished then
              get_state <= get_add_high;
            end if;
            
          when get_add_high =>
            if reader_state = finished then
              get_state <= get_data;
            end if;
            
          when get_data =>
            if reader_state = finished then
              get_state <= finished;
            end if;
          
          when finished =>
            get_state <= idle;
          
          when others =>
            NULL;
        end case;
      end if;
    end if;
  end process get_data_fsm;
  
  transmit_fsm : process(clk, get_state, transmitter_state, input.eot) begin
    if rising_edge(clk) then
      if ((get_state = send_header) or
          (get_state = send_add_low) or
          (get_state = send_add_high)) then
        case transmitter_state is
          when idle =>
            if input.ready = '1' then
              transmitter_state <= set_data;
            end if;
          
          when set_data =>
            transmitter_state <= trans_data;
          
          when trans_data =>
            transmitter_state <= pause;
          
          when pause =>
            if input.eot = '1' then
              transmitter_state <= finished;
            end if;
          
          when finished =>
            transmitter_state <= idle;
        
          when others =>
            NULL;
        end case;
      end if;
    end if;
  end process transmit_fsm;
  
  read_fsm : process(clk, get_state, reader_state, input.eoc) begin
    if rising_edge(clk) then
      if ((get_state = get_header) or
          (get_state = get_add_low) or
          (get_state = get_add_high) or
          (get_state = get_data)) then
        case reader_state is
          when idle =>
            reader_state <= wait_data;
          
          when wait_data =>
            if input.eoc = '1' then
              reader_state <= read_data;
            end if;
          
          when read_data =>
            reader_state <= pause;
          
          when pause =>
            if input.eoc = '0' then
              reader_state <= finished;
            end if;
          
          when finished =>
            reader_state <= idle;
        
          when others =>
            NULL;
        end case;
      end if;
    end if;
  end process read_fsm;
  
  -- Outputs
  with state select
    output.data_ack <= '1' when wait_clear,
                       'Z' when idle,
                       '0' when others;
  
  with transmitter_state select
    output.write <= '1' when trans_data,
                    '0' when others;
  
  output.muart_input <= idle          when transmitter_state /= set_data and transmitter_state /= trans_data else
                        header        when get_state = send_header   else
                        data_add_high when get_state = send_add_high else
                        data_add_low  when get_state = send_add_low  else
                        data_data     when get_state = send_data     else
                        idle;
  
 output.muart_output <= clear_data when state = idle              else
                        idle       when reader_state /= read_data else
                        header     when get_state = get_header    else
                         data_data  when get_state = get_data      else
                         idle;
end data_control_unit_arch;
