library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.mmu_types.all;

entity mmu_control_unit is
  port (
    input  : in  control_in_type;
    output : out control_out_type;
    clk    : in  std_logic
  );
end mmu_control_unit;

architecture mmu_control_unit_arch of mmu_control_unit is
  signal data_in  : data_in_type;
  signal data_out : data_out_type;
  signal inst_in  : inst_in_type;
  signal inst_out : inst_out_type;
  
  component data_control_unit is
    port (
      input  : in  data_in_type;
      output : out data_out_type;
      clk    : in  std_logic
    );
  end component;
  
  component inst_control_unit is
    port (
      input  : in  inst_in_type;
      output : out inst_out_type;
      clk    : in  std_logic
    );
  end component;
begin

    inst_in.eoc          <= input.eoc;
    inst_in.eot          <= input.eot;
    inst_in.ready        <= input.ready;
    inst_in.inst_req     <= input.inst_req;
    inst_in.fr           <= input.fr;
    inst_in.inst_or_data <= input.inst_or_data;
    inst_in.rw           <= input.rw;


    output.write <= inst_out.write;
    output.inst_or_data <= inst_out.inst_or_data;
    output.inst_ack <= inst_out.inst_ack;
    output.muart_input <= inst_out.muart_input;
    output.muart_output <= inst_out.muart_output;
    
  data_cu : data_control_unit port map (data_in, data_out, clk);
  inst_cu : inst_control_unit port map (inst_in, inst_out, clk);
end mmu_control_unit_arch;