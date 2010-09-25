--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:29:18 09/28/2010
-- Design Name:   
-- Module Name:   C:/Users/Henry/Desktop/enel353g1/testRoutines.vhd
-- Project Name:  enel353g1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: alu
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testRoutines IS
END testRoutines;
 
ARCHITECTURE behavior OF testRoutines IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         clk : IN  std_logic;
         f : IN  std_logic_vector(3 downto 0);
         rx : IN  std_logic_vector(7 downto 0);
         ry : IN  std_logic_vector(7 downto 0);
         ro : OUT  std_logic_vector(7 downto 0);
         Cin : IN  std_logic;
         sr : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal f : std_logic_vector(3 downto 0) := (others => '0');
   signal rx : std_logic_vector(7 downto 0) := (others => '0');
   signal ry : std_logic_vector(7 downto 0) := (others => '0');
   signal Cin : std_logic := '0';

 	--Outputs
   signal ro : std_logic_vector(7 downto 0);
   signal sr : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          clk => clk,
          f => f,
          rx => rx,
          ry => ry,
          ro => ro,
          Cin => Cin,
          sr => sr
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 10 ns;	

      wait for clk_period*2;

      -- insert stimulus here
		f <= "0001";       -- Test AND Function
		rx <= "01010101";
		ry <= "10101010";
		wait for 2 ns;
		
		rx <= "00001000";
		ry <= "00000000";
		wait for 2 ns;
		
		rx <= "11111111";
		ry <= "00000000";
		wait for 2 ns;
		
		rx <= "00000000";
		ry <= "11111111";
		wait for 2 ns;
				
		rx <= "11111111";
		ry <= "11111111";
		wait for 2 ns;

		rx <= "11111111";
		ry <= "11111111";
		wait for 2 ns;

		rx <= "10101010";
		ry <= "10101010";
		wait for 2 ns;
		
		rx <= "01010101";
		ry <= "01010101";
		wait for 2 ns;
		
		f <= "0011";       -- Test OR Function
		rx <= "01010101";
		ry <= "10101010";
		wait for 2 ns;
		
		rx <= "00001000";
		ry <= "00000000";
		wait for 2 ns;
		
		rx <= "11111111";
		ry <= "00000000";
		wait for 2 ns;
		
		rx <= "00000000";
		ry <= "11111111";
		wait for 2 ns;
				
		rx <= "11111111";
		ry <= "11111111";
		wait for 2 ns;

		rx <= "11111111";
		ry <= "11111111";
		wait for 2 ns;

		rx <= "10101010";
		ry <= "10101010";
		wait for 2 ns;
		
		rx <= "01010101";
		ry <= "01010101";
		wait for 2 ns;
		
		f <= "0101";       -- Test NOT Function
		rx <= "01010101";
		ry <= "10101010";
		wait for 2 ns;
		
		rx <= "00001000";
		ry <= "00000000";
		wait for 2 ns;
		
		rx <= "11111111";
		ry <= "00000000";
		wait for 2 ns;
		
		rx <= "00000000";
		ry <= "11111111";
		wait for 2 ns;
				
		rx <= "11111111";
		ry <= "11111111";
		wait for 2 ns;

		rx <= "11111111";
		ry <= "11111111";
		wait for 2 ns;

		rx <= "10101010";
		ry <= "10101010";
		wait for 2 ns;
		
		rx <= "01010101";
		ry <= "01010101";
		wait for 2 ns;
		
		f <= "0111";       -- Test XOR Function
		rx <= "01010101";
		ry <= "10101010";
		wait for 2 ns;
		
		rx <= "00001000";
		ry <= "00000000";
		wait for 2 ns;
		
		rx <= "11111111";
		ry <= "00000000";
		wait for 2 ns;
		
		rx <= "00000000";
		ry <= "11111111";
		wait for 2 ns;
				
		rx <= "11111111";
		ry <= "11111111";
		wait for 2 ns;

		rx <= "11111111";
		ry <= "11111111";
		wait for 2 ns;

		rx <= "10101010";
		ry <= "10101010";
		wait for 2 ns;
		
		rx <= "01010101";
		ry <= "01010101";
		wait for 2 ns;

		

      wait;
   end process;
--
--	process
--     type pattern_type is record
--	    --  The inputs of the adder.
--       f : bit_vector(3 downto 0);
--		 rx : bit_vector(7 downto 0);
--		 ry : bit_vector(7 downto 0);
--       Cin : bit;
--       --  The expected outputs of the adder.
--		 ro : bit_vector(7 downto 0);
--       sr : bit_vector(2 downto 0);
--     end record;
--     --  The patterns to apply.
--     type pattern_array is array (natural range <>) of pattern_type;
--       constant patterns : pattern_array :=
--       --(( f    ,  rx       ,  ry       , Cin,  ro,         sr  ),
--			(("0001", "00000000", "00000000", '0', "00000000", "000"),
--          ("0001", "00000000", "00000000", '0', "00000000", "000"),
--          ("0001", "00000000", "00000000", '0', "00000000", "000"));
--     begin
--     --  Check each pattern.
--       for i in patterns'range loop
--          --  Set the inputs.
--          f   <= patterns(i).f;
--          rx  <= patterns(i).rx;
--          ry  <= patterns(i).ry;
--			 Cin <= patterns(i).Cin;
--          --  Wait for the results.
--          wait for 1 ns;
--          --  Check the outputs.
--          assert ro = patterns(i).ro
--             report "bad sum value" severity error;
--          assert sr = patterns(i).sr
--             report "bad carray out value" severity error;
--       end loop;
--       assert false report "end of test" severity note;
--       --  Wait forever; this will finish the simulation.
--       wait;
--    end process;
END;
