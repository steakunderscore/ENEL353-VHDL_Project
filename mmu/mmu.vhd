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
--use work.buses;
--
--type inst_bus is
--    record
--      add  : std_logic_vector(11 downto 0); -- Address lines.
--      data : std_logic_vector(15 downto 0); -- Data lines.
--      req  : std_logic;                     -- Pulled low to request bus usage.
--      ack  : std_logic;                     -- Pulled high to inform of request completion.
--    end record;
--
--
--  type data_bus is
--    record
--      add  : std_logic_vector(15 downto 0); -- Address lines.
--      data : std_logic_vector(7 downto 0);  -- Data lines.
--      red  : std_logic;                     -- High for a read request, low for a write request.
--      req  : std_logic;                     -- Pulled low to request bus usage.
--      ack  : std_logic;                     -- Pulled high to inform of request completion.
--    end record;


entity mmu is
  port (
    clk      : in    std_logic;
    data_bus : inout buses.data_bus;
    inst_bus : inout buses.inst_bus;
    recieve_pin : in std_logic;
    transfer_pin : out std_logic;
  )
end mmu;

architecture mmu_arch of mmu is
  type state is (idle, check_add, get_data, put_data, wait_clear);

  -- instruction bus
  signal inst_add  : std_logic_vector(11 downto 0); -- Address lines.
  signal inst_data : std_logic_vector(15 downto 0); -- Data lines.
  signal inst_req  : std_logic;                     -- Pulled low to request bus usage.
  signal inst_ack  : std_logic;                     -- Pulled high to inform of request completion.

  -- data bus
  signal data_add  : std_logic_vector(15 downto 0); -- Address lines.
  signal data_data : std_logic_vector(7 downto 0);  -- Data lines.
  signal data_red  : std_logic;                     -- High for a read request, low for a write request.
  signal data_req  : std_logic;                     -- Pulled low to request bus usage.
  signal data_ack  : std_logic;                     -- Pulled high to inform of request completion.

  -- internal stuff
  signal inst_state : state := idle;
  signal inst_address : std_logic_vector( 11 downto 0 );
  signal data_state : state := idle;
  signal data_data : std_logic_vector(7 downto 0);
  signal data_address : std_logic_vector( 15 downto 0 );
  
  begin
    muart : minimal_uart_core port map (
      clock <= clk,
      eoc   <= end_of_collection,
      outp  <= muart_out,
      rxd   <= recieve_pin,
      txd   <= transfer_pin,
      eot   <= end_of_transmission,
      inp   <= muart_in,
      ready <= ready,
      wr    <= write
    );

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
              data_state <= get_data;
            else
              data_state <= put_data;
            end if;
          else
            data_state <= idle;
          end if;
        
        when get_data =>
          data_bus.data <= --incoming data;
          data_bus.ack <= '0';
          data_state <= wait_clear;
        
        when put_data =>
          -- put data
          data_bus.ack <= '0';
          data_state <= wait_clear;
        
        when wait_clear =>
          if (rising_edge(clk) and inst_bus.req = '1') then
            data_bus.ack <= '1'
            data_state <= idle;
          end if;
      end case;
    end process data_fsm;

end mmu_arch;

