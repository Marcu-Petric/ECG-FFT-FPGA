library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_module is
    Port ( 
        aclk : in std_logic;
        aresetn : in std_logic;
        s_axis_data_tvalid : in STD_LOGIC;
        s_axis_data_tready : out STD_LOGIC;
        s_axis_data_tdata : in STD_LOGIC_VECTOR(31 downto 0);
        s_axis_data_tlast : in STD_LOGIC;
        brady : out std_logic;
        tachy : out std_logic;
        dng : out std_logic;
        dead : out std_logic;
        bpm_o: out STD_LOGIC_VECTOR(15 downto 0)
    );
end top_module;

architecture Behavioral of top_module is

    component Data_Filtering is
        Port (
            aclk : in STD_LOGIC;
            aresetn : in STD_LOGIC;
            s_axis_data_tdata : in STD_LOGIC_VECTOR(31 DOWNTO 0);
            s_axis_data_tvalid : in STD_LOGIC;
            s_axis_data_tready : out STD_LOGIC;
            s_axis_data_tlast : in STD_LOGIC;
            m_axis_data_tdata : out STD_LOGIC_VECTOR(31 DOWNTO 0);
            m_axis_data_tvalid : out STD_LOGIC;
            m_axis_data_tready : in STD_LOGIC;
            m_axis_data_tlast : out STD_LOGIC
        );
    end component;

    component R_Peak_Detection is
        Port (
            aclk : in STD_LOGIC;
            aresetn : in STD_LOGIC;
            s_axis_ecg_tvalid : in STD_LOGIC;
            s_axis_ecg_tready : out STD_LOGIC;
            s_axis_ecg_tdata : in STD_LOGIC_VECTOR(31 downto 0);
            r_peak : out STD_LOGIC
        );
    end component;

    component R_R_Interval is
        Port (
            aclk : in std_logic;
            clk : in std_logic;
            r_peak : in std_logic;
            m_axis_interval_tvalid : out STD_LOGIC;
            m_axis_interval_tready : in STD_LOGIC;
            m_axis_interval_tdata : out STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;

    component Move_Avr is
        Port (
            aclk : in STD_LOGIC;
            s_axis_val_tvalid : in STD_LOGIC;
            s_axis_val_tready : out STD_LOGIC;
            s_axis_val_tdata : in STD_LOGIC_VECTOR(31 DOWNTO 0);
            m_axis_sum_tvalid : out STD_LOGIC;
            m_axis_sum_tready : in STD_LOGIC;
            m_axis_sum_tdata : out STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;

    component BPM is
        Port (
            aclk : in STD_LOGIC;
            s_axis_val_tvalid : in STD_LOGIC;
            s_axis_val_tready : out STD_LOGIC;
            s_axis_val_tdata : in STD_LOGIC_VECTOR(31 DOWNTO 0);
            bpm : out std_logic_vector(15 downto 0)
        );
    end component;

    component Anorm_Detect is
        Port (
            aclk : in STD_LOGIC;
            s_axis_val_tvalid : in STD_LOGIC;
            s_axis_val_tready : out STD_LOGIC;
            s_axis_val_tdata : in STD_LOGIC_VECTOR(31 DOWNTO 0);
            brady : out std_logic;
            tachy : out std_logic;
            dng : out std_logic;
            dead : out std_logic
        );
    end component;

    signal filtered_tdata : std_logic_vector(31 downto 0);
    signal filtered_tvalid, filtered_tready, filtered_tlast : std_logic;
    
    signal r_peak_detected : std_logic;
    
    signal rr_interval_tdata : std_logic_vector(31 downto 0);
    signal rr_interval_tvalid, rr_interval_tready : std_logic;
    
    signal mavg_tdata : std_logic_vector(31 downto 0);
    signal mavg_tvalid, mavg_tready : std_logic;
    
    signal bpm_value : std_logic_vector(15 downto 0);
    signal bpm_tdata : std_logic_vector(31 downto 0);

    signal clk_100hz : std_logic := '0';
    signal clk_counter : integer := 0;
    constant CLK_DIVIDER : integer := 500000;

begin

    process(aclk)
    begin
        if rising_edge(aclk) then
            if clk_counter = CLK_DIVIDER-1 then
                clk_counter <= 0;
                clk_100hz <= not clk_100hz;
            else
                clk_counter <= clk_counter + 1;
            end if;
        end if;
    end process;

    Filter_inst: Data_Filtering
        port map (
            aclk => aclk,
            aresetn => aresetn,
            s_axis_data_tdata => s_axis_data_tdata,
            s_axis_data_tvalid => s_axis_data_tvalid,
            s_axis_data_tready => s_axis_data_tready,
            s_axis_data_tlast => s_axis_data_tlast,
            m_axis_data_tdata => filtered_tdata,
            m_axis_data_tvalid => filtered_tvalid,
            m_axis_data_tready => filtered_tready,
            m_axis_data_tlast => filtered_tlast
        );

    RPeak_inst: R_Peak_Detection
        port map (
            aclk => aclk,
            aresetn => aresetn,
            s_axis_ecg_tvalid => filtered_tvalid,
            s_axis_ecg_tready => filtered_tready,
            s_axis_ecg_tdata => filtered_tdata,
            r_peak => r_peak_detected
        );

    RR_inst: R_R_Interval
        port map (
            aclk => aclk,
            clk => clk_100hz,
            r_peak => r_peak_detected,
            m_axis_interval_tvalid => rr_interval_tvalid,
            m_axis_interval_tready => rr_interval_tready,
            m_axis_interval_tdata => rr_interval_tdata
        );

    MovAvg_inst: Move_Avr
        port map (
            aclk => aclk,
            s_axis_val_tvalid => rr_interval_tvalid,
            s_axis_val_tready => rr_interval_tready,
            s_axis_val_tdata => rr_interval_tdata,
            m_axis_sum_tvalid => mavg_tvalid,
            m_axis_sum_tready => mavg_tready,
            m_axis_sum_tdata => mavg_tdata
        );

    BPM_inst: BPM
        port map (
            aclk => aclk,
            s_axis_val_tvalid => mavg_tvalid,
            s_axis_val_tready => mavg_tready,
            s_axis_val_tdata => mavg_tdata,
            bpm => bpm_value
        );

    bpm_tdata <= x"0000" & bpm_value;

    Anomaly_inst: Anorm_Detect
        port map (
            aclk => aclk,
            s_axis_val_tvalid => '1',
            s_axis_val_tready => open,
            s_axis_val_tdata => bpm_tdata,
            brady => brady,
            tachy => tachy,
            dng => dng,
            dead => dead
        );
    
    bpm_o <= bpm_value;
    
end Behavioral;