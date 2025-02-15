library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Filter_Unit is
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
end Filter_Unit;

architecture Behavioral of Filter_Unit is
    
  -- Internal signals
  signal input_ready  : STD_LOGIC := '1'; -- Always ready to accept input
  signal data_valid   : STD_LOGIC := '0'; -- Holds output valid state
  signal filtered_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Filtered output data

  -- Constants for filtering
  constant LOW_FREQ_INDEX   : integer := 1;   -- Example: Index for 0.5 Hz (adjust based on FFT size and Fs)
  constant HIGH_FREQ_INDEX  : integer := 30; -- Example: Index for 50 Hz
  constant FFT_SIZE         : integer := 512; -- FFT size (example)

  -- State to track frequency bins
  signal bin_index : integer := 0;

begin

  -- Assign ready and valid signals
  s_axis_data_tready <= input_ready;
  m_axis_data_tvalid <= data_valid;
  m_axis_data_tdata <= filtered_tdata;

  -- Filter process
  process(aclk)
  begin
    if rising_edge(aclk) then
      if aresetn = '0' then
        -- Reset state
        bin_index <= 0;
        data_valid <= '0';
      elsif s_axis_data_tvalid = '1' and input_ready = '1' then
        -- Increment bin index
        if bin_index < FFT_SIZE - 1 then
          bin_index <= bin_index + 1;
        else
          bin_index <= 0; -- Wrap around for next frame
        end if;

        -- Apply bandpass filtering
        if bin_index >= LOW_FREQ_INDEX and bin_index <= HIGH_FREQ_INDEX then
          -- Pass the frequency bin
          filtered_tdata <= s_axis_data_tdata;
        else
          -- Zero out unwanted bins
          filtered_tdata <= (others => '0');
        end if;

        -- Forward filtered data
        data_valid <= '1';
        m_axis_data_tlast <= s_axis_data_tlast; -- Pass through the last signal
      else
        -- No valid input
        data_valid <= '0';
      end if;
    end if;
  end process;

end Behavioral;