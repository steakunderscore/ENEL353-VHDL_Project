-- Authors:
--      Wim Looman, Forrest McKerchar

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.mmu_types.all;
use work.mmu_control_unit;
use work.header_builder;
use work.header_decoder;
use work.reg8;

use work.minimal_uart_core;

  entity mmu_main is
    port (
      -- instruction bus
      inst_add  : in  std_logic_vector(11 downto 0); -- Address lines.
      inst_data : out std_logic_vector(15 downto 0); -- Data lines.
      inst_req  : in  std_logic;                     -- Pulled low to request bus usage.
      inst_ack  : out std_logic;                     -- Pulled high to inform of request completion.
      -- data bus
      data_add  : in    std_logic_vector(15 downto 0); -- Address lines.
      data_line : inout std_logic_vector(7 downto 0);  -- Data lines.
      data_read : in    std_logic;                     -- High for a read request, low for a write request.
      data_req  : in    std_logic;                     -- Pulled low to request bus usage.
      data_ack  : inout std_logic;                     -- Pulled high to inform of request completion.
      -- extras
      clk          : in  std_logic;
      receive_pin  : in  std_logic;
      transfer_pin : out std_logic
    );
  end mmu_main;
  
  architecture mmu_arch of mmu_main is
    component mmu_control_unit is
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
    end component;
  
    component header_builder is
      port (
        read_write : in  std_logic; -- 1 = read, 0 = write
        inst_data  : in  std_logic; -- 1 = inst, 0 = data
        header     : out std_logic_vector(7 downto 0)
      );
    end component;
  
    component header_decoder is
      port (
        read_write    : out  std_logic; -- 1 = read, 0 = write
        fetch_request : out std_logic;
        inst_data     : out  std_logic; -- 1 = inst, 0 = data
        header        : in std_logic_vector(7 downto 0)
      );
    end component;
    
    component minimal_uart_core is
      port(
        clock : in    std_logic;
        eoc   : out   std_logic;
        outp  : inout std_logic_vector(7 downto 0) := "ZZZZZZZZ";
        rxd   : in    std_logic;
        txd   : out   std_logic;
        eot   : out   std_logic;
        inp   : in    std_logic_vector(7 downto 0);
        ready : out   std_logic;
        wr    : in    std_logic
      );
    end component;
    
    component reg8 IS
      port(
        I      : in  std_logic_vector(7 downto 0);
        clock  : in  std_logic;
        enable : in  std_logic;
        reset  : in  std_logic;
        Q      : out std_logic_vector(7 downto 0)
      );
    end component;
    
    
    signal eoc          : std_logic;
    signal eot          : std_logic;
    signal ready        : std_logic;
    signal fr           : std_logic;
    signal inst_or_data_in : std_logic;
    signal rw           : std_logic;

    signal write        : std_logic;
    signal inst_or_data_out : std_logic;
    signal muart_input  : muart_input_state;
    signal muart_output : muart_output_state;

    signal muart_out : std_logic_vector(7 downto 0);
    signal muart_in  : std_logic_vector(7 downto 0);
    signal header_in   : std_logic_vector(7 downto 0);
    signal header_out  : std_logic_vector(7 downto 0);
    signal inst_data_high_enable : std_logic;
    signal inst_data_low_enable : std_logic;
    signal data_data_enable : std_logic;
    signal data_line_tri : std_logic_vector(7 downto 0);

    begin
    muart : minimal_uart_core port map (
      clk, 
      eoc, 
      muart_out, 
      receive_pin, 
      transfer_pin, 
      eot, 
      muart_in, 
      ready, 
      write
    );
    cu  : mmu_control_unit port map (
      eoc, 
      eot, 
      ready, 
      data_read, 
      data_req, 
      data_add(0), 
      inst_req, 
      fr, 
      inst_or_data_in, 
      rw, 
      write, 
      inst_or_data_out, 
      inst_ack, 
      data_ack, 
      muart_input, 
      muart_output, 
      clk
    );
    hb  : header_builder port map (
      data_read, 
      inst_or_data_out, 
      header_out
    );
    hd  : header_decoder port map (
      rw, 
      fr, 
      inst_or_data_in, 
      header_in
    );
    idh : reg8 port map (
      muart_out, 
      clk, 
      inst_data_high_enable, 
      '0', 
      inst_data(15 downto 8)
    );
    idl : reg8 port map (
      muart_out, 
      clk, 
      inst_data_low_enable,  
      '0', 
      inst_data(7  downto 0)
    );
    dd  : reg8 port map (
      muart_out, 
      clk, 
      data_data_enable,
      '0', 
      data_line_tri
    );
    
    with muart_input select
      muart_in <=  header_out                     when header,
                   "0000" & inst_add(11 downto 8) when inst_add_high,
                   inst_add(7  downto 0)          when inst_add_low,
                   '0' & data_add(15 downto 9)    when data_add_high,
                   data_add(8  downto 1)          when data_add_low,
                   data_line                      when data_data,
                   (others => '0')                when others;
    
    route_output : process(muart_output, muart_out) begin
      header_in <= (others => '0');
      inst_data_high_enable <= '0';
      inst_data_low_enable <= '0';
      data_data_enable <= '0';
      case muart_output is
        when header =>
          header_in <= muart_out;
          
        when inst_data_high =>
          inst_data_high_enable <= '1';
          
        when inst_data_low =>
          inst_data_low_enable <= '1';
          
        when data_data =>
          data_data_enable <= '1';
        when others =>
          NULL;
      end case;
    end process;
    
    data_line <= data_line_tri when data_add(0) = '1' and data_read = '1' else
                 (others => 'Z');
    
  end mmu_arch;
