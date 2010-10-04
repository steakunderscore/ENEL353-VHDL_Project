----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:09:00 09/15/2010 
-- Design Name: 
-- Module Name:    mmu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.buses;

entity mmu is
  port (
    clk      : in    std_logic;
    data_bus : inout buses.data_bus;
    inst_bus : inout buses.inst_bus;
end mmu;

architecture mmu_arch of mmu is
  type state is (idle, check_add, read_add, get_data, write_add, put_data, wait_clear);
  
  signal inst_state : state := idle;
  signal inst_address : std_logic_vector( 11 downto 0 );
  signal data_state : state := idle;
  signal data_data : std_logic_vector(7 downto 0);
  signal data_address : std_logic_vector( 15 downto 0 );
  
  begin
    inst_fsm : process(inst_state, inst_bus.req, clk)
    begin
      case inst_state is
        when idle =>
          if (rising_edge(clk) and inst_bus.req = '0') then
            inst_state <= get_data;
          end if;
        
        when get_data =>
          inst_bus.data <= --incoming data;
          inst_bus.ack <= '0';
          inst_state <= wait_clear;
        
        when wait_clear =>
          if (rising_edge(clk) and inst_bus.req = '1') then
            inst_bus.ack <= '1';
            inst_state <= idle;
          end if;
      end case;
    end process inst_fsm;
    
    data_fsm : process(data_state, data_bus.req, clk)
    begin
      case data_state is
        when idle =>
          if (rising_edge(clk) and data_bus.req = '0') then
            data_state <= check_add;
          end if;
        
        when check_add =>
          if (rising_edge(clk) and data_bus.req = '0' and data_bus.address(0) = '1') then
            if data_bus.red = '1' then
              data_state <= read_add;
            else
              data_state <= write_add;
            end if;
          else
            data_state <= idle;
          end if;
        
        when read_add =>
          data_address <= data_bus.add;
          data_state <= get_data;
        
        when get_data =>
          data_bus.data <= --incoming data;
          data_bus.ack <= '0';
          data_state <= wait_data;
        
        when write_add =>
          data_address <= data_bus.add;
          data_data <= data_bus.data;
          data_state <= put_data;
        
        when put_data =>
          -- put data
          data_bus.ack <= '0'
          data_state <= wait_clear
        
        when wait_clear =>
          if (rising_edge(clk) and inst_bus.req = '1') then
            data_bus.ack <= '1'
            data_state <= idle;
          end if;
      end case;
    end process data_fsm;

end mmu_arch;

