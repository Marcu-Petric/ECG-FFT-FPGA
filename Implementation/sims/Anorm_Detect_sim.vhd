library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Anorm_Detect_sim is
end Anorm_Detect_sim;

architecture Tb of BPM_sim is

component Anorm_Detect is
    port (
        aclk : IN STD_LOGIC;
        s_axis_val_tvalid : IN STD_LOGIC;
        s_axis_val_tready : OUT STD_LOGIC;
        s_axis_val_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        brady: out std_logic; -- Bradycardia
        tachy: out std_logic; -- Tachycardia
        dng: out std_logic; -- Dangerous heart function
        dead: out std_logic -- 0 BPM
    );
end component;

constant T : time := 20 ns;

signal aclk, s_axis_val_tvalid, s_axis_val_tready : std_logic := '0';
signal s_axis_val_tdata : std_logic_vector(31 downto 0) :=  (others => '0');
signal bpm_r : std_logic_vector(15 downto 0) := (others => '0');
signal brady, tachy, dng, dead : std_logic := '0';

begin

    aclk <= not aclk after T / 2;
    
                                                     
    s_axis_val_tdata <= x"000001D", x"0000001F" after 2*T, x"00000000" after 6*T, x"00000000" after 10*T, x"00000064" after 14*T, x"0000001F" after 18*T, x"000000C9" after 22*T, x"00000064" after 26*T, x"00000020" after 30*T, x"00000010" after 34*T;

    s_axis_val_tvalid <= '0', '1' after T, '0' after 2*T, '1' after 5*T, '0' after 6*T, '1' after 9*T, '0' after 10*T, '1' after 13*T, '0' after 14*T, '1' after 17*T, '0' after 18*T, '1' after 21*T, '0' after 22*T,  '1' after 25*T, '0' after 26*T, '1' after 29*T, '0' after 30*T, '1' after 33*T, '0' after 34*T, '1' after 37*T, '0' after 38*T;

    -- design under test
    dut : BPM port map (
        aclk => aclk,
        s_axis_val_tvalid => s_axis_val_tvalid,
        s_axis_val_tready => s_axis_val_tready,
        s_axis_val_tdata => s_axis_val_tdata,
        brady => brady,
        tachy => tachy,
        dng => dng,
        dead => dead
    );

    
end Tb;
