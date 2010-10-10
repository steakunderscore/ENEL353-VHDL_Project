library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;

package mmu is
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
      data_red  : in    std_logic;                     -- High for a read request, low for a write request.
      data_req  : in    std_logic;                     -- Pulled low to request bus usage.
      data_ack  : inout std_logic;                     -- Pulled high to inform of request completion.
      -- extras
      clk          : in  std_logic;
      recieve_pin  : in  std_logic;
      transfer_pin : out std_logic;
    )
  end mmu;
  
  architecture mmu_arch of mmu is
    signal muart_out : std_logic_vector(7 downto 0);
    signal muart_in  : std_logic_vector(7 downto 0);
    signal control_in  : control_in_type;
    signal control_out : control_out_type;
    signal header_in   : std_logic_vector(7 downto 0);
    signal header_out  : std_logic_vector(7 downto 0);

    begin
      muart : minimal_uart_core port map (
        clock <= clk,
        eoc   <= control_in.eoc,
        outp  <= muart_out,
        rxd   <= recieve_pin,
        txd   <= transfer_pin,
        eot   <= control_in.eot,
        inp   <= muart_in,
        ready <= control_in.ready,
        wr    <= control_out.write
      );

      cu : control_unit port map (
        input  <= control_in,
        output <= control_out,
        clk    <= clk
      );

      hb : header_builder port map (
        rw        <= data_red,
        inst_data <= control_out.inst_or_data,
        header    <= header_out
      );

      hd : header_decoder port map (
        fr        <= control_in.fr,
        inst_data <= control_in.inst_or_data,
        header    <= header_in
      );
  end mmu_arch;
end mmu;
