LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY Multiplier_serial IS
    GENERIC (N : NATURAL := 16);
    PORT (
        clk, reset, start : IN STD_LOGIC;
        a : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        b : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        z : OUT STD_LOGIC_VECTOR(2 * N - 1 DOWNTO 0);
        Ready : OUT STD_LOGIC
    );
END Multiplier_serial;

ARCHITECTURE Multiplier_serial1 OF Multiplier_serial IS

    SIGNAL reg_A : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    SIGNAL reg_a0 : STD_LOGIC;
    SIGNAL sig1, sig2, sum : STD_LOGIC_VECTOR(N DOWNTO 0);
    SIGNAL acc_reg, shift_reg : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    SIGNAL inv, cout, enable, ready1 : STD_LOGIC;
    SIGNAL cnt : INTEGER;

    COMPONENT adder IS
    GENERIC (N : NATURAL := 16); -- Adder width 
    PORT (
        x, y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        cin : IN STD_LOGIC;
        cout : OUT STD_LOGIC;
        s : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
    END COMPONENT;

BEGIN
    control : PROCESS (clk, reset) IS
    BEGIN
        IF reset = '1' THEN
            cnt <= 0;
            inv <= '0';
            enable <= '0';
        ELSIF rising_edge (clk) THEN
            inv <= '0';
            IF start = '1' THEN
                cnt <= 0;
                enable <= '1';
            ELSE
                    IF cnt = N - 1 THEN
                        cnt <= N - 1;
                        enable <= '0';
                    ELSE
                        cnt <= cnt + 1;
                    END IF;
                    IF cnt = N - 2 THEN
                        inv <= '1';
                    ELSE
                        inv <= '0';
                    END IF;
                END IF;
            END IF;
    END PROCESS;
    --shift reg 1
    p0 : PROCESS (clk, reset) IS
    BEGIN
        IF reset = '1' THEN
            reg_A <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN

            IF start = '1' THEN
                reg_A <= a;
            ELSIF enable = '1' THEN
                reg_A <= reg_A(N-1) & reg_A(N-1 DOWNTO 1);
            END IF;
        END IF;
    END PROCESS;
    reg_a0 <= reg_A(0);
    --ni or kola

    LAB1 : FOR i IN 0 TO N-1 GENERATE
        LAB2 : sig2 (i) <= (reg_a0 AND b(i)) XOR inv;
    END GENERATE;
    sig2(N) <= sig2(N-1);


    --sabirac
    l0 : adder
    GENERIC MAP(N => N + 1)
    PORT MAP(
        x => sig2,
        y => sig1,
        cin => inv,
        cout => cout,
        s => sum );

    sig1 <= acc_reg(N - 1) & acc_reg(N - 1 DOWNTO 0);


    --REG
    PROCESS (clk, reset) IS
    BEGIN
        IF reset = '1' THEN
            acc_reg <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF start = '1' THEN
                acc_reg <= (OTHERS => '0');
            ELSIF enable = '1' THEN
                acc_reg <= sum(N DOWNTO 1);
            END IF;
        END IF;
    END PROCESS;

    --shift reg 2
    PROCESS (clk, reset) IS
    BEGIN
        IF reset = '1' THEN
            shift_reg <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF start = '1' THEN
                shift_reg <= (OTHERS => '0');
            ELSIF enable = '1' THEN
                shift_reg <= sum(0) & shift_reg(N - 1 DOWNTO 1);
            END IF;
        END IF;
    END PROCESS;

    -- counter and control logic

    z(2 * N - 1 DOWNTO 0) <= acc_reg & shift_reg
    WHEN ready1 = '1' ELSE
    (OTHERS => '0');
    ready1 <= NOT (start OR enable);
    Ready <= ready1;

END ARCHITECTURE Multiplier_serial1;