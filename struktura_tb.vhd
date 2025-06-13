LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Multiplier_serial_tb IS
    GENERIC (
        N : NATURAL := 16
    );
END Multiplier_serial_tb;

ARCHITECTURE Multiplier_serial1_tb OF Multiplier_serial_tb IS

    SIGNAL A : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    SIGNAL B : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    SIGNAL Z : STD_LOGIC_VECTOR(2 * N - 1 DOWNTO 0);
    SIGNAL clk, reset, start : STD_LOGIC;
    SIGNAL ready : STD_LOGIC;
    SIGNAL ENDSIM : BOOLEAN := false;
    CONSTANT clk_period : TIME := 100 ns;

    component  Multiplier_serial IS
    GENERIC (N : NATURAL := 16);
    PORT (
        clk, reset, start : IN STD_LOGIC;
        a : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        b : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        z : OUT STD_LOGIC_VECTOR(2 * N - 1 DOWNTO 0);
        Ready : OUT STD_LOGIC
    );
   END component  Multiplier_serial;
BEGIN
   
    utt : Multiplier_serial  
    generic map (N=> N)
    PORT MAP (clk => clk, reset => reset, start => start, a => A, b => B, z => Z, Ready => ready);
    
    clk_process : PROCESS
    BEGIN       
       if ENDSIM = false then
            clk <= '0';
            WAIT FOR clk_period / 2;
            clk <= '1';
            WAIT FOR clk_period / 2;
        else
          WAIT;
        end if;  
    END PROCESS clk_process;

    lab: PROCESS IS
    BEGIN
       
        WAIT FOR 10ns;
        
        reset <= '1';        
        WAIT FOR clk_period;
        reset <= '0';

        WAIT FOR clk_period;
        A <= x"FFFD";  -- -3
        B <= x"FFFD";  -- -3
        WAIT FOR clk_period;
        start <= '1';
        WAIT FOR clk_period;
        start <= '0';
        WAIT FOR 15*clk_period;

        WAIT FOR clk_period;
        A <= x"0003";
        B <= x"0003";
        WAIT FOR clk_period;
        start <= '1';
        WAIT FOR clk_period;
        start <= '0';
        WAIT FOR 15*clk_period;


        WAIT FOR clk_period;
        A <= x"FFFD";  -- -3
        B <= x"0003";
        WAIT FOR clk_period;
        start <= '1';
        WAIT FOR clk_period;
        start <= '0';
        WAIT FOR 15*clk_period;

        WAIT FOR clk_period;
        B <= x"FFFD";  -- -3
        A <= x"0003";
        WAIT FOR clk_period;
        start <= '1';
        WAIT FOR clk_period;
        start <= '0';
        WAIT FOR 15*clk_period;
      
        ENDSIM <= true;
        WAIT;
    END PROCESS lab;

END ARCHITECTURE Multiplier_serial1_tb;