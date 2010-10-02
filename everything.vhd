library work;
use work.cpu.cpu;
use work.mmu.mmu;
use work.io.io; 

architecture everything_arch of everything is
  signal clk      : std_logic;
  signal data_bus : ;
  signal inst_bus : ;
  
  begin
    entity cpu(cpu_arch)
      port map(
        clk => clk,
        data_bus => data_bus,
        inst_bus => inst_bus
      );
    entity mmu(mmu_arch)
      port map(
        clk => clk,
        data_bus => data_bus,
        inst_bus => inst_bus
      );
    entity io(io_arch)
      port map(
        clk => clk,
        data_bus => data_bus
      );
end architecture everything_arch