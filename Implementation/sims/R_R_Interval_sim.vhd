library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity R_R_Interval is
end R_R_Interval;

architecture Tb of R_R_Interval is

component R_R_Interval is
    port (
        aclk : in std_logic; -- axi4 clock
        clk : in std_logic; -- 100 Hz ( 10 ms )
        r_peak: in std_logic; -- 1 when a R peak is detected
        m_axis_interval_tvalid : OUT STD_LOGIC;
        m_axis_interval_tready : IN STD_LOGIC;
        m_axis_interval_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
end component;

constant T : time := 10 ns;
constant T2 : time := 1 ms;

signal aclk, m_axis_interval_tvalid, m_axis_interval_tready : std_logic := '0';
signal m_axis_interval_tdata : std_logic_vector(31 downto 0) :=  (others => '0');
signal r_peak, clk;

begin

    aclk <= not aclk after T / 2;
    
    clk <= not clk after T2/2;

    r_peak <= '0', '1' after 4 ns, '0' after 6 ns, 1 after (6 ns + 1 ms);

    -- design under test
    dut : Anorm_Detect port map (
        aclk => aclk,
        clk => clk,
        r_peak => r_peak,
        m_axis_interval_tvalid => m_axis_interval_tvalid,
        m_axis_interval_tready => m_axis_interval_tready,
        m_axis_interval_tdata => m_axis_interval_tdata,

    );

    
end Tb;
