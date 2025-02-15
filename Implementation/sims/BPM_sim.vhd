library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BPM_sim is
end BPM_sim;

architecture Tb of BPM_sim is

component BPM is
    port (
        aclk : IN STD_LOGIC;
        s_axis_val_tvalid : IN STD_LOGIC;
        s_axis_val_tready : OUT STD_LOGIC;
        s_axis_val_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        bpm: out std_logic_vector(3 downto 0)
    );
end component;

constant T : time := 20 ns;

signal aclk, s_axis_val_tvalid, s_axis_val_tready : std_logic := '0';
signal s_axis_val_tdata : std_logic_vector(31 downto 0) :=  (others => '0');
signal bpm : std_logic_vector(3 downto 0) := '0';

begin

    aclk <= not aclk after T / 2;
    
    aclk <= not aclk after T / 2;
                        --100          --75                    --120
    s_axis_val_tdata <= x"00000258", x"00000320" after 2*T, x"000001F4" after 6*T;

    s_axis_val_tvalid <= '0', '1' after T, '0' after 2*T, '1' after 5*T, '0' after 6*T, '1' after 9*T, '0' after 10*T;

    -- design under test
    dut : BPM port map (
        aclk => aclk,
        s_axis_val_tvalid => s_axis_val_tvalid,
        s_axis_val_tready => s_axis_val_tready,
        s_axis_val_tdata => s_axis_val_tdata,
        bpm => s_axis_val_tdata
    );

    
end Tb;
