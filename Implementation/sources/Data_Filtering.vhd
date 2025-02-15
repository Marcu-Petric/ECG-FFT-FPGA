library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Data_Filtering is
  Port (
    aclk         : in  STD_LOGIC;  -- Clock
    aresetn      : in  STD_LOGIC;  -- Active-low reset
    -- Input AXI Stream
    s_axis_data_tdata : in  STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_data_tvalid: in  STD_LOGIC;
    s_axis_data_tready: out STD_LOGIC;
    s_axis_data_tlast : in  STD_LOGIC;
    -- Output AXI Stream
    m_axis_data_tdata : out STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_data_tvalid: out STD_LOGIC;
    m_axis_data_tready: in  STD_LOGIC;
    m_axis_data_tlast : out STD_LOGIC
  );
end Data_Filtering;

architecture Behavioral of Data_Filtering is

    component Filter_Unit is
      Port (
        aclk         : in  STD_LOGIC;  -- Clock
        aresetn      : in  STD_LOGIC;  -- Active-low reset
        -- Input AXI Stream
        s_axis_data_tdata : in  STD_LOGIC_VECTOR(31 DOWNTO 0); -- 16-bit real + 16-bit imaginary
        s_axis_data_tvalid: in  STD_LOGIC;
        s_axis_data_tready: out STD_LOGIC;
        s_axis_data_tlast : in  STD_LOGIC;
        -- Output AXI Stream
        m_axis_data_tdata : out STD_LOGIC_VECTOR(31 DOWNTO 0); -- Filtered frequency-domain data
        m_axis_data_tvalid: out STD_LOGIC;
        m_axis_data_tready: in  STD_LOGIC;
        m_axis_data_tlast : out STD_LOGIC
      );
    end component;

    component xFFT_unti is 
        port (
            aclk : IN STD_LOGIC;
            aresetn : IN STD_LOGIC;
            s_axis_config_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            s_axis_config_tvalid : IN STD_LOGIC;
            s_axis_config_tready : OUT STD_LOGIC;
            s_axis_data_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            s_axis_data_tvalid : IN STD_LOGIC;
            s_axis_data_tready : OUT STD_LOGIC;
            s_axis_data_tlast : IN STD_LOGIC;
            m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            m_axis_data_tvalid : OUT STD_LOGIC;
            m_axis_data_tready : IN STD_LOGIC;
            m_axis_data_tlast : OUT STD_LOGIC;
            event_frame_started : OUT STD_LOGIC;
            event_tlast_unexpected : OUT STD_LOGIC;
            event_tlast_missing : OUT STD_LOGIC;
            event_status_channel_halt : OUT STD_LOGIC;
            event_data_in_channel_halt : OUT STD_LOGIC;
            event_data_out_channel_halt : OUT STD_LOGIC
        );
    end component;

    -- Signals for FFT
    signal fft_config_tdata   : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0356"; -- Forward FFT
    signal fft_config_tvalid  : STD_LOGIC := '1';
    signal fft_config_tready  : STD_LOGIC;
    signal fft_out_tdata      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal fft_out_tvalid     : STD_LOGIC;
    signal fft_out_tready     : STD_LOGIC := '1';
    signal fft_out_tlast      : STD_LOGIC;

    -- Signals for Filter
    signal filter_in_tdata    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal filter_in_tvalid   : STD_LOGIC;
    signal filter_in_tready   : STD_LOGIC;
    signal filter_in_tlast    : STD_LOGIC;
    signal filter_out_tdata   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal filter_out_tvalid  : STD_LOGIC;
    signal filter_out_tready  : STD_LOGIC := '1';
    signal filter_out_tlast   : STD_LOGIC;

    -- Signals for IFFT
    signal ifft_config_tdata  : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0357"; -- Inverse FFT
    signal ifft_config_tvalid : STD_LOGIC := '1';
    signal ifft_config_tready : STD_LOGIC;
    signal ifft_out_tdata     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ifft_out_tvalid    : STD_LOGIC;
    signal ifft_out_tready    : STD_LOGIC;
    signal ifft_out_tlast     : STD_LOGIC;
    
    signal real_part:  STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal real_part_fft, real_part_fft_fil:  STD_LOGIC_VECTOR(15 DOWNTO 0);


begin
    
    real_part <= s_axis_data_tdata(15 downto 0);
    
  -- FFT Instance
  FFT_Unit: xFFT_unti
    port map (
        aclk                => aclk,
        aresetn             => aresetn,
        s_axis_config_tdata => fft_config_tdata,
        s_axis_config_tvalid=> fft_config_tvalid,
        s_axis_config_tready=> fft_config_tready,
        s_axis_data_tdata   => s_axis_data_tdata,
        s_axis_data_tvalid  => s_axis_data_tvalid,
        s_axis_data_tready  => s_axis_data_tready,
        s_axis_data_tlast   => s_axis_data_tlast,
        m_axis_data_tdata   => fft_out_tdata,
        m_axis_data_tvalid  => fft_out_tvalid,
        m_axis_data_tready  => fft_out_tready,
        m_axis_data_tlast   => fft_out_tlast,
        event_frame_started => open,
        event_tlast_unexpected => open,
        event_tlast_missing => open,
        event_status_channel_halt => open,
        event_data_in_channel_halt => open,
        event_data_out_channel_halt => open
    );
    
    real_part_fft <= fft_out_tdata(15 downto 0);
    
  -- Filter Module
Filter_mod: Filter_Unit
    port map (
        aclk                => aclk,
        aresetn             => aresetn,
        s_axis_data_tdata   => fft_out_tdata,
        s_axis_data_tvalid  => fft_out_tvalid,
        s_axis_data_tready  => fft_out_tready,
        s_axis_data_tlast   => fft_out_tlast,
        m_axis_data_tdata   => filter_out_tdata,
        m_axis_data_tvalid  => filter_out_tvalid,
        m_axis_data_tready  => filter_out_tready,
        m_axis_data_tlast   => filter_out_tlast
    );

    real_part_fft_fil <= filter_out_tdata(15 downto 0);

  -- IFFT Instance
  IFFT_Unit: xFFT_unti
    port map (
        aclk                => aclk,
        aresetn             => aresetn,
        s_axis_config_tdata => ifft_config_tdata,
        s_axis_config_tvalid=> ifft_config_tvalid,
        s_axis_config_tready=> ifft_config_tready,
        s_axis_data_tdata   => filter_out_tdata,
        s_axis_data_tvalid  => filter_out_tvalid,
        s_axis_data_tready  => filter_out_tready,
        s_axis_data_tlast   => filter_out_tlast,
        m_axis_data_tdata   => m_axis_data_tdata,
        m_axis_data_tvalid  => m_axis_data_tvalid,
        m_axis_data_tready  => m_axis_data_tready,
        m_axis_data_tlast   => m_axis_data_tlast,
        event_frame_started => open,
        event_tlast_unexpected => open,
        event_tlast_missing => open,
        event_status_channel_halt => open,
        event_data_in_channel_halt => open,
        event_data_out_channel_halt => open
    );
end Behavioral;
