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
        eoc          : in std_logic; -- High on muart has finished collecting data ??
        eot          : in std_logic; -- High on muart has finished transmitting data.
        ready        : in std_logic; -- ??
        data_read    : in std_logic; -- High if the data line is requesting a read, low for write.
        data_req     : in std_logic; -- Low when the data address is valid and should be read.
        data_add_0   : in std_logic; -- High for memory address, not IO.
        inst_req     : in std_logic; -- Low when the instruction address is valid and should be read.
        fr           : in std_logic; -- High if latest input headers fetch request was set.
        inst_or_data_in : in std_logic; -- High if latest input packet was an instruction packet.
        rw           : in std_logic; -- High if latest input packet had read/write set.
        write        : out std_logic; -- High to start muart writing data.
        inst_or_data_out : out std_logic; -- High if current output packet is an instruction packet.
        inst_ack     : out std_logic; -- Low when the inst is ready to be read by CPU. High otherwise.
        data_ack     : out std_logic; -- Low when the data is ready to be read by CPU. High impedance otherwise.
        muart_input  : out muart_input_state; -- State to multiplex the muart's input
        muart_output : out muart_output_state; -- State to multiplex the muart's output.
        clk    : in  std_logic
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
    
    
    signal eoc          : std_logic; -- High on muart has finished collecting data ??
    signal eot          : std_logic; -- High on muart has finished transmitting data.
    signal ready        : std_logic; -- ??
    signal fr           : std_logic; -- High if latest input headers fetch request was set.
    signal inst_or_data_in : std_logic; -- High if latest input packet was an instruction packet.
    signal rw           : std_logic; -- High if latest input packet had read/write set.

    signal write        : std_logic; -- High to start muart writing data.
    signal inst_or_data_out : std_logic; -- High if current output packet is an instruction packet.
    signal muart_input  : muart_input_state; -- State to multiplex the muart's input
    signal muart_output : muart_output_state; -- State to multiplex the muart's output.

    signal muart_out : std_logic_vector(7 downto 0);
    signal muart_in  : std_logic_vector(7 downto 0);
    signal header_in   : std_logic_vector(7 downto 0);
    signal header_out  : std_logic_vector(7 downto 0);
    signal inst_data_high_enable : std_logic;
    signal inst_data_low_enable : std_logic;
    signal data_data_enable : std_logic;
    signal data_line_tri : std_logic_vector(7 downto 0);

    begin
    muart : minimal_uart_core port map (clk, eoc, muart_out, receive_pin, transfer_pin, eot, muart_in, ready, write);
    cu  : mmu_control_unit port map (eoc, eot, ready, data_read, data_req, data_add(0), inst_req, fr, inst_or_data_in, rw, write, inst_or_data_out, inst_ack, data_ack, muart_input, muart_output, clk);
    hb  : header_builder port map (data_read, inst_or_data_out, header_out);
    hd  : header_decoder port map (rw, fr, inst_or_data_in, header_in);
    idh : reg8 port map (muart_out, clk, inst_data_high_enable, '0', inst_data(15 downto 8));
    idl : reg8 port map (muart_out, clk, inst_data_low_enable,  '0', inst_data(7  downto 0));
    dd  : reg8 port map (muart_out, clk, data_data_enable,      '0', data_line_tri);
    
    with muart_input select
      muart_in <=  header_out                               when header,
                   "0000" & inst_add(11 downto 8)           when inst_add_high,
                   inst_add(7  downto 0)                    when inst_add_low,
                   '0' & data_add(14 downto 8)              when data_add_high,
                   data_add(7  downto 0)                    when data_add_low,
                   data_line                                when data_data,
                   (others => '0')                          when others;
    
    route_output : process(muart_output, muart_out) begin
      header_in <= (others => '0');
      inst_data_high_enable <= '0';
      inst_data_low_enable <= '0';
      data_data_enable <= '0';
      case muart_output is
        when header         =>
          header_in <= muart_out;
          
        when inst_data_high =>
          inst_data_high_enable <= '1';
          
        when inst_data_low  =>
          inst_data_low_enable <= '1';
          
        when data_data      =>
          data_data_enable <= '1';
        when others =>
          NULL;
      end case;
    end process;
    
    data_line <= data_line_tri when data_add(0) = '1' else
                 (others => 'Z');
    
  end mmu_arch;
