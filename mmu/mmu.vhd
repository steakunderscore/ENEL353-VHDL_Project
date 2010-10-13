library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.mmu_types.all;
use work.mmu_control_unit;
use work.header_builder;
use work.header_decoder;

use work.minimal_uart_core;

  entity mmu is
    port (
      -- instruction bus
      inst_add  : in  std_logic_vector(11 downto 0); -- Address lines.
      inst_data : out std_logic_vector(15 downto 0); -- Data lines.
      inst_req  : in  std_logic;                     -- Pulled low to request bus usage.
      inst_ack  : out std_logic;                     -- Pulled high to inform of request completion.
      -- data bus
      data_add  : in    std_logic_vector(15 downto 0); -- Address lines.
      data_data : inout std_logic_vector(7 downto 0);  -- Data lines.
      data_read : in    std_logic;                     -- High for a read request, low for a write request.
      data_req  : in    std_logic;                     -- Pulled low to request bus usage.
      data_ack  : inout std_logic;                     -- Pulled high to inform of request completion.
      -- extras
      clk          : in  std_logic;
      recieve_pin  : in  std_logic;
      transfer_pin : out std_logic
    );
  end mmu;
  
  architecture mmu_arch of mmu is
    signal muart_out : std_logic_vector(7 downto 0);
    signal muart_in  : std_logic_vector(7 downto 0);
    signal control_in  : control_in_type;
    signal control_out : control_out_type;
    signal header_in   : std_logic_vector(7 downto 0);
    signal header_out  : std_logic_vector(7 downto 0);

    component mmu_control_unit is
      port (
        input  : in  control_in_type;
        output : out control_out_type;
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

    begin
    control_in.data_add_0 <= data_add(0);
    control_in.data_read  <= data_read;
    control_in.data_req   <= data_req;
    control_in.inst_req   <= inst_req;

    inst_ack <= control_out.inst_ack;
    data_ack <= control_out.data_ack;

      muart : minimal_uart_core port map (
        clk,
        control_in.eoc,
        muart_out,
        recieve_pin,
        transfer_pin,
        control_in.eot,
        muart_in,
        control_in.ready,
        control_out.write
      );

      cu : mmu_control_unit port map (
        control_in,
        control_out,
        clk
      );

      hb : header_builder port map (
        data_read,
        control_out.inst_or_data,
        header_out
      );

      hd : header_decoder port map (
			control_in.rw,
        control_in.fr,
        control_in.inst_or_data,
        header_in
      );
  end mmu_arch;
