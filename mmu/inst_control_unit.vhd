-- Authors:
--      Wim Looman, Forrest McKerchar

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.mmu_types.all;

entity inst_control_unit is
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
end inst_control_unit;

architecture inst_control_unit_arch of inst_control_unit is
  type state_type is (idle, get_data, wait_clear);
  type m_state_type is (idle,
                        send_header,   send_add_high,   send_add_low,
                        get_header,    get_add_high,    get_add_low,
                        get_data_high, get_data_low,    finished);
  type read_state_type is (idle, wait_data, read_data, pause, finished);
  type transmit_state_type is (idle, set_data, trans_data, pause, finished);
  signal state, next_state : state_type := idle;
  signal get_state, next_get_state : m_state_type := idle;
  signal reader_state, next_reader_state : read_state_type := idle;
  signal transmitter_state, next_transmitter_state : transmit_state_type := idle;
begin
  inst_fsm : process(state, inst_req, clk) begin
    case state is
      when idle =>
        if (inst_req = '0') then
          next_state <= get_data;
        end if;
      
      when get_data =>
        if (get_state = finished) then
          next_state <= wait_clear;
        end if;
      
      when wait_clear =>
        if (inst_req = '1') then
          next_state <= idle;
        end if;
      
      when others =>
        NULL;
    end case;
  end process inst_fsm;
  
  get_inst_fsm : process(state, clk) begin
    if state = get_data then
      case get_state is
        when idle =>
          next_get_state <= send_header;
        
        when send_header =>
          if transmitter_state = finished then
            next_get_state <= send_add_low;
          end if;
        
        when send_add_low =>
          if transmitter_state = finished then
            next_get_state <= send_add_high;
          end if;
        
        when send_add_high =>
          if transmitter_state = finished then
            next_get_state <= get_header;
          end if;
        
        when get_header =>
          if reader_state = finished then
            next_get_state <= get_add_low;
          end if;
          
        when get_add_low =>
          if reader_state = finished then
            next_get_state <= get_add_high;
          end if;
          
        when get_add_high =>
          if reader_state = finished then
            next_get_state <= get_data_low;
          end if;
          
        when get_data_low =>
          if reader_state = finished then
            next_get_state <= get_data_high;
          end if;
          
        when get_data_high =>
          if reader_state = finished then
            next_get_state <= finished;
          end if;
        
        when finished =>
          next_get_state <= idle;
        
        when others =>
          NULL;
      end case;
    end if;
  end process get_inst_fsm;
  
  transmit_fsm : process(clk, get_state, transmitter_state, eot) begin
    if ((get_state = send_header) or
        (get_state = send_add_low) or
        (get_state = send_add_high)) then
      case transmitter_state is
        when idle =>
          if ready = '1' and eot = '0' then
            next_transmitter_state <= set_data;
          end if;
        
        when set_data =>
          next_transmitter_state <= trans_data;
        
        when trans_data =>
          next_transmitter_state <= pause;
        
        when pause =>
          if eot = '1' then
            next_transmitter_state <= finished;
          end if;
        
        when finished =>
          next_transmitter_state <= idle;
      
        when others =>
          NULL;
      end case;
    end if;
  end process transmit_fsm;
  
  read_fsm : process(clk, get_state, reader_state, eoc) begin
    if ((get_state = get_header) or
        (get_state = get_add_low) or
        (get_state = get_add_high) or
        (get_state = get_data_low) or
        (get_state = get_data_high)) then
      case reader_state is
        when idle =>
          next_reader_state <= wait_data;
        
        when wait_data =>
          if eoc = '1' then
            next_reader_state <= read_data;
          end if;
        
        when read_data =>
          next_reader_state <= pause;
        
        when pause =>
          if eoc = '0' then
            next_reader_state <= finished;
          end if;
        
        when finished =>
          next_reader_state <= idle;
      
        when others =>
          NULL;
      end case;
    end if;
  end process read_fsm;

  switch_states : process(clk, next_state, next_get_state, next_reader_state, next_transmitter_state) begin
    if rising_edge(clk) then
      state <= next_state;
      get_state <= next_get_state;
      reader_state <= next_reader_state;
      transmitter_state <= next_transmitter_state;
    end if;
  end process switch_states;
  
  -- Outputs
  with state select
    inst_ack <= '1' when wait_clear,
                       '0' when others;
  
  with state select
    inst_or_data <= '0' when idle,
                           '1' when others;
  
  with transmitter_state select
    write <= '1' when trans_data,
                    '0' when others;
  

  muart_input <= idle          when transmitter_state /= set_data and transmitter_state /= trans_data else
                        header        when get_state = send_header         else
                        inst_add_high when get_state = send_add_high       else
                        inst_add_low  when get_state = send_add_low        else
                        idle;
  
  muart_output <= idle           when reader_state /= read_data   else
                         header         when get_state = get_header    else
                         inst_data_high when get_state = get_data_high else
                         inst_data_low  when get_state = get_data_low  else
                         idle;
end inst_control_unit_arch;