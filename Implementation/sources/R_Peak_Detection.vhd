library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity R_Peak_Detection is
    Port (
        aclk : in STD_LOGIC;
        aresetn : in STD_LOGIC;
        -- Input AXI Stream
        s_axis_ecg_tvalid : in STD_LOGIC;
        s_axis_ecg_tready : out STD_LOGIC;
        s_axis_ecg_tdata : in STD_LOGIC_VECTOR(31 downto 0);
        -- Output
        r_peak : out STD_LOGIC
    );
end R_Peak_Detection;

architecture rtl of R_Peak_Detection is

    constant MINIMUM_SAMPLES : std_logic_vector(31 downto 0) := x"00000032"; 
    constant DRIFT : signed(31 downto 0) := x"00000001";
    constant INITIAL_THRESHOLD : signed(31 downto 0) := x"00100000"; 


    signal data_ready : STD_LOGIC := '1';
    signal sample_count : std_logic_vector(31 downto 0) := (others => '0');
    signal current_sample : signed(31 downto 0);
    signal prev_sample : signed(31 downto 0) := (others => '0');
    signal prev_prev_sample : signed(31 downto 0) := (others => '0');
    signal adaptive_threshold : signed(31 downto 0) := INITIAL_THRESHOLD;
    signal r_peak_s : std_logic := '0';

begin

    s_axis_ecg_tready <= data_ready;
    current_sample <= signed(s_axis_ecg_tdata);
    r_peak <= r_peak_s;


    process(aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                r_peak_s <= '0';
                sample_count <= (others => '0');
                prev_sample <= (others => '0');
                prev_prev_sample <= (others => '0');
                adaptive_threshold <= INITIAL_THRESHOLD;
            elsif s_axis_ecg_tvalid = '1' and data_ready = '1' then

                r_peak_s <= '0';
                
   
                if current_sample > prev_sample and prev_sample > prev_prev_sample then

                    if current_sample > adaptive_threshold and sample_count > MINIMUM_SAMPLES then
                        r_peak_s <= '1';
                        sample_count <= (others => '0');  
                        
                        adaptive_threshold <= '0' & (adaptive_threshold(31 downto 1) + current_sample(31 downto 1));
                    end if;
                end if;
                
                if adaptive_threshold > DRIFT then
                    adaptive_threshold <= adaptive_threshold - DRIFT;
                end if;
                
                prev_prev_sample <= prev_sample;
                prev_sample <= current_sample;
                
                if r_peak_s = '0' then
                    sample_count <= sample_count + '1';
                end if;
            end if;
        end if;
    end process;

end architecture;