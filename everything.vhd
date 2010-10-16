library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;

entity everything is
  port (
        clk   : in  std_logic;
        reset : in  std_logic;
        tx    : out std_logic;
        rx    : in  std_logic;
        sw1   : in  std_logic;
        sw2   : in  std_logic
  );
end everything;

architecture everything_arch of everything is
  component cpu IS
    PORT(
      -- instruction bus
      inst_add  : out std_logic_vector(11 downto 0); -- Address lines.
      inst_data : in  std_logic_vector(15 downto 0); -- Data lines.
      inst_req  : out std_logic;                     -- Pulled low to request bus usage.
      inst_ack  : in  std_logic;                     -- Pulled high to inform of request completion.
      -- data bus
      data_add  : out    std_logic_vector(15 downto 0); -- Address lines.
      data_line : inout std_logic_vector(7 downto 0);  -- Data lines.
      data_read : out    std_logic;                     -- High for a read request, low for a write request.
      data_req  : out    std_logic;                     -- Pulled low to request bus usage.
      data_ack  : inout std_logic;                     -- Pulled high to inform of request completion.
      -- extras
      clk       : in  std_logic;
      reset     : in  std_logic
    );
  end component;
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
  END component;
  component IO is
       PORT(
            -- data bus --
            data_add    : IN      std_logic_vector(15 DOWNTO 0); -- address lines --
            data_data   : INOUT   std_logic_vector(7 DOWNTO 0);  -- data lines --
            data_read   : INOUT   std_logic;                     -- pulled high for read, low for write --
            data_req    : INOUT   std_logic;                     -- pulled low to request bus usage --
            data_ack    : INOUT   std_logic;                     -- pulled high to inform request completion --
            -- io --
            clk         : IN      std_logic;
            sw1         : IN      std_logic;
            sw2         : IN      std_logic);
            --leds      : OUT std_logic_vector(7 DOWNTO 0);
  END component;
  -- instruction bus
  signal inst_add  : std_logic_vector(11 downto 0); -- Address lines.
  signal inst_data : std_logic_vector(15 downto 0); -- Data lines.
  signal inst_req  : std_logic;                     -- Pulled low to request bus usage.
  signal inst_ack  : std_logic;                     -- Pulled high to inform of request completion.
  -- data bus
  signal data_add  : std_logic_vector(15 downto 0); -- Address lines.
  signal data_line : std_logic_vector(7 downto 0);  -- Data lines.
  signal data_read : std_logic;                     -- High for a read request, low for a write request.
  signal data_req  : std_logic;                     -- Pulled low to request bus usage.
  signal data_ack  : std_logic;                     -- Pulled high to inform of request completion.
  
  begin
    c : cpu port map(
      -- instruction bus
      inst_add  => inst_add, -- Instruction address
      inst_data => inst_data,-- Instruction data
      inst_req  => inst_req, -- Request 
      inst_ack  => inst_ack, -- Instruction obtained
      -- data bus
      data_add  => data_add, -- Data address
      data_line => data_line,-- Data
      data_read => data_read,-- 1 for read, 0 for write
      data_req  => data_req, -- Request
      data_ack  => data_ack, -- Data written to/ read from
      -- extras
      clk       => clk,
      reset     => reset
      );
    m : mmu_main port map(
      -- instruction bus
      inst_add     => inst_add,  -- Address lines.
      inst_data    => inst_data, -- Data lines.
      inst_req     => inst_req,  -- Pulled low to request bus usage.
      inst_ack     => inst_ack,  -- Pulled high to inform of request completion.
      -- data bus
      data_add     => data_add,  -- Address lines.
      data_line    => data_line, -- Data lines.
      data_read    => data_read, -- High for a read request, low for a write request.
      data_req     => data_req,  -- Pulled low to request bus usage.
      data_ack     => data_ack,  -- Pulled high to inform of request completion.
      -- extras
      clk          => clk,
      receive_pin  => rx,
      transfer_pin => tx
    );
    i : io  port map(
            clk         => clk,
            data_add    => data_add,
            data_data   => data_line,
            data_read   => data_read,
            data_req    => data_req,
            data_ack    => data_ack,
            -- io --
            sw1         => sw1,
            sw2         => sw2
      );
end architecture everything_arch;
