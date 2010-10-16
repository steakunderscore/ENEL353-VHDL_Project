library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.mmu_main;
use work.minimal_uart_core;
use work.txt_util.all;

entity data_tb is
end data_tb;

architecture tb of data_tb is
  component mmu_main is
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
  end component;
  
  component IO is
    PORT(
      -- data bus --
      data_add    : IN      std_logic_vector(15 DOWNTO 0);    -- address lines --
      data_data : INOUT     std_logic_vector(7 DOWNTO 0);   -- data lines --
      data_read : INOUT     std_logic;                -- pulled high for read, low for write --
      data_req    : INOUT   std_logic;                -- pulled low to request bus usage --
      data_ack    : INOUT   std_logic;                -- pulled high to inform request completion --
      -- io --
      clk         : IN      std_logic;
      sw1         : IN      std_logic;
      sw2         : IN      std_logic
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
    
  signal inst_add     : std_logic_vector(11 downto 0);
  signal inst_data    : std_logic_vector(15 downto 0);
  signal inst_req     : std_logic := '1';
  signal inst_ack     : std_logic;
  signal data_add     : std_logic_vector(15 downto 0);
  signal data_line    : std_logic_vector(7 downto 0);
  signal data_read    : std_logic;
  signal data_req     : std_logic;
  signal data_ack     : std_logic;
  signal clk          : std_logic;
  signal receive_pin  : std_logic;
  signal transfer_pin : std_logic;
  signal sw1, sw2 : std_logic;
  
  signal eoc, rxd, txd, eot, ready, wr: std_logic;
  signal outp, inp : std_logic_vector(7 downto 0);
begin
  m : mmu_main port map (inst_add, inst_data, inst_req, inst_ack, data_add, data_line, data_read, data_req, data_ack, clk, receive_pin, transfer_pin);
  i : IO       port map (data_add, data_line, data_read, data_req, data_ack, clk, sw1, sw2);
  muart : minimal_uart_core port map (clk, eoc, outp, rxd, txd, eot, inp, ready, wr);
  
  rxd <= transfer_pin;
  receive_pin <= txd;
  
  clk_gen : process begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process;
  
  data_test : process
    type pattern_type is record
      data_add      : std_logic_vector(15 downto 0);
      recv_head     : std_logic_vector( 7 downto 0);
      send_head     : std_logic_vector( 7 downto 0);
      data_data     : std_logic_vector( 7 downto 0);
      switch_data   : std_logic_vector( 1 downto 0);
      rw            : std_logic;
    end record;
    type pattern_array is array (natural range <>) of pattern_type;
    constant patterns : pattern_array :=
-- data_add, recv_head, send_head, data_data, switch_data, rw
    ((x"0581", x"80", x"00", x"A7", "00", '1' ),
     (x"0273", x"00", x"00", x"5E", "00", '0' ));
  begin
    wr <= '0';
    data_req <= '1';
    for i in patterns'range loop
      wait for 10000 ns;
      data_add <= patterns(i).data_add;
      data_read <= patterns(i).rw;
      wait for 20 ns;
      if patterns(i).rw = '0' then
        data_line <= patterns(1).data_data;
      else
        data_line <= (others => 'Z');
      end if;
      wait for 20 ns;
      data_req <= '0';
      
      if patterns(i).data_add(0) = '1' then
        wait until eoc'event;
        assert outp = patterns(i).recv_head
          report "Bad header expected '" & str(patterns(i).recv_head) & "' recieved '" & str(outp) & "'"
          severity error;
        wait until eoc'event;
        
        assert false report "passed header" severity note;
        
        wait until eoc'event;
        assert outp = patterns(i).data_add(8 downto 1)
          report "Bad address low expected '" & str(patterns(i).data_add(7 downto 0)) & "' recieved '" & str(outp) & "'"
          severity error;
        wait until eoc'event;
        
        assert false report "passed address low" severity note;
        
        wait until eoc'event;
        assert outp = "0" & patterns(i).data_add(15 downto 9)
          report "Bad address high expected '" & str(patterns(i).data_add(11 downto 8)) & "' recieved '" & str(outp) & "'"
          severity error;
        wait until eoc'event;
        
        assert false report "passed address high" severity note;
        if patterns(i).rw = '0' then
          wait until eoc'event;
          assert outp = patterns(i).data_data
            report "Bad data expected '" & str(patterns(i).data_data) & "' recieved '" & str(outp) & "'"
            severity error;
          wait until eoc'event;
          
          assert false report "passed data" severity note;
        else
          wait for 100 ns;
          inp <= patterns(i).send_head;
          wait for 20 ns;
          wr <= '1';
          wait for 20 ns;
          wr <= '0';
          wait until eot'event;
          wait until eot'event;
          
          
          wait for 100 ns;
          inp <= patterns(i).data_add(8 downto 1);
          wait for 20 ns;
          wr <= '1';
          wait for 20 ns;
          wr <= '0';
          wait until eot'event;
          wait until eot'event;


          wait for 100 ns;
          inp <=  "0" & patterns(i).data_add(15 downto 9);
          wait for 20 ns;
          wr <= '1';
          wait for 20 ns;
          wr <= '0';
          wait until eot'event;
          wait until eot'event;


          wait for 100 ns;
          inp <= patterns(i).data_data;
          wait for 20 ns;
          wr <= '1';
          wait for 20 ns;
          wr <= '0';
          wait until eot'event;
          wait until eot'event;
        end if;
      else
        
      end if;
      
      assert data_ack = '1'
        report "receipt not acknowledged"
        severity error;
      
      if  patterns(i).rw = '1' then
        assert data_line = patterns(i).data_data
          report "Wrong data recieve expected '" & str(patterns(i).data_data) & "' recieved '" & str(data_line) & "'"
          severity error;
      end if;
      
      assert false report "finished transmission" severity note;
      
      wait for 20 ns;

      data_req <= '1';
    end loop;
    wait;
  end process;
end tb;