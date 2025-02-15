library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity R_R_Interval_tb is
end R_R_Interval_tb;

architecture sim of R_R_Interval_tb is

    component R_R_Interval is
        port (
            clk : in std_logic; -- 100 Hz ( 10 ms )
            rst : in std_logic; -- active low, async
            r_peak: in std_logic; -- 1 when a R peak is detected
            r_interval: out std_logic_vector(15 downto 0) -- 0 - not yet measured, > 0 otherwise
        );
    end component;
    
    constant clk_period : time := 10 ms;

    signal clk, r_peak : std_logic := '0';
    signal rst : std_logic := '1';
    signal r_interval : std_logic_vector(15 downto 0) := (others => '0');

begin

    clk <= not clk after clk_period / 2;

    DUT : R_R_Interval port map(
        clk => clk,
        rst => rst,
        r_peak => r_peak,
        r_interval => r_interval
    );

    rst <= '0', '1' after 10 ms;
    
    r_peak <= '0', '1' after 95ms, '0' after 101ms, '1' after 1100 ms;

end architecture;
