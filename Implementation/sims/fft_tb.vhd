library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FFT_IFFT_Testbench is
end FFT_IFFT_Testbench;

architecture Behavioral of FFT_IFFT_Testbench is

    -- Signals for FFT
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';

    -- FFT Signals
    signal fft_config_tdata : std_logic_vector(15 downto 0) := (others => '0');
    signal fft_config_tvalid : std_logic := '0';
    signal fft_config_tready : std_logic;

    signal fft_data_tdata : std_logic_vector(31 downto 0);
    signal fft_data_tvalid : std_logic := '0';
    signal fft_data_tready : std_logic;
    signal fft_data_tlast : std_logic := '0';

    signal fft_output_tdata : std_logic_vector(31 downto 0);
    signal fft_output_tvalid : std_logic;
    signal fft_output_tready : std_logic := '1'; -- Always ready to accept output
    signal fft_output_tlast : std_logic;

    -- IFFT Signals
    signal ifft_config_tdata : std_logic_vector(15 downto 0) := (others => '0');
    signal ifft_config_tvalid : std_logic := '0';
    signal ifft_config_tready : std_logic;

    signal ifft_data_tdata : std_logic_vector(31 downto 0);
    signal ifft_data_tvalid : std_logic := '0';
    signal ifft_data_tready : std_logic;
    signal ifft_data_tlast : std_logic := '0';

    signal ifft_output_tdata : std_logic_vector(31 downto 0);
    signal ifft_output_tvalid : std_logic;
    signal ifft_output_tready : std_logic := '1';
    signal ifft_output_tlast : std_logic;

    -- Test Signal
    type sin_wave_type is array (0 to 15) of std_logic_vector(31 downto 0);
    constant sin_wave : sin_wave_type := (
        x"00000000", -- 0
        x"18F8B83C", -- sin(2π * 1 / 16) * 2^15
        x"30FBC54C", -- sin(2π * 2 / 16) * 2^15
        x"471CECE7", -- sin(2π * 3 / 16) * 2^15
        x"5A82799A", -- sin(2π * 4 / 16) * 2^15
        x"6A6D98A4", -- sin(2π * 5 / 16) * 2^15
        x"7641AF3C", -- sin(2π * 6 / 16) * 2^15
        x"7D8A5F40", -- sin(2π * 7 / 16) * 2^15
        x"7FFFFFFF", -- sin(2π * 8 / 16) * 2^15
        x"7D8A5F40", -- sin(2π * 9 / 16) * 2^15
        x"7641AF3C", -- sin(2π * 10 / 16) * 2^15
        x"6A6D98A4", -- sin(2π * 11 / 16) * 2^15
        x"5A82799A", -- sin(2π * 12 / 16) * 2^15
        x"471CECE7", -- sin(2π * 13 / 16) * 2^15
        x"30FBC54C", -- sin(2π * 14 / 16) * 2^15
        x"18F8B83C"  -- sin(2π * 15 / 16) * 2^15
    );

    signal sample_counter : integer := 0;

    -- Clock Period
    constant clk_period : time := 10 ns;

begin

    -- Clock Generation
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Reset Process
    reset_process : process
    begin
        reset <= '1';
        wait for 100 ns; -- Assert reset for 100 ns
        reset <= '0';
        wait;
    end process;

    -- FFT Instance
    FFT_INST : entity work.xfft_0
        port map (
            aclk => clk,
            s_axis_config_tdata => fft_config_tdata,
            s_axis_config_tvalid => fft_config_tvalid,
            s_axis_config_tready => fft_config_tready,
            s_axis_data_tdata => fft_data_tdata,
            s_axis_data_tvalid => fft_data_tvalid,
            s_axis_data_tready => fft_data_tready,
            s_axis_data_tlast => fft_data_tlast,
            m_axis_data_tdata => fft_output_tdata,
            m_axis_data_tvalid => fft_output_tvalid,
            m_axis_data_tready => fft_output_tready,
            m_axis_data_tlast => fft_output_tlast
        );

    -- IFFT Instance
    IFFT_INST : entity work.xfft_0
        port map (
            aclk => clk,
            s_axis_config_tdata => ifft_config_tdata,
            s_axis_config_tvalid => ifft_config_tvalid,
            s_axis_config_tready => ifft_config_tready,
            s_axis_data_tdata => fft_output_tdata, -- FFT output to IFFT input
            s_axis_data_tvalid => fft_output_tvalid,
            s_axis_data_tready => ifft_data_tready,
            s_axis_data_tlast => fft_output_tlast,
            m_axis_data_tdata => ifft_output_tdata,
            m_axis_data_tvalid => ifft_output_tvalid,
            m_axis_data_tready => ifft_output_tready,
            m_axis_data_tlast => ifft_output_tlast
        );

    -- Input Feed for FFT
    input_feed : process(clk, reset)
    begin
        if reset = '1' then
            fft_config_tvalid <= '0';
            fft_data_tvalid <= '0';
            fft_data_tdata <= (others => '0');
            sample_counter <= 0;
        elsif rising_edge(clk) then
            -- Send FFT configuration
            if fft_config_tvalid = '0' then
                fft_config_tdata <= x"0001"; -- Forward FFT
                fft_config_tvalid <= '1';
            elsif fft_config_tready = '1' then
                fft_config_tvalid <= '0';
            end if;

            -- Send sinusoidal samples to FFT
            if sample_counter < 16 then
                fft_data_tvalid <= '1';
                fft_data_tdata <= sin_wave(sample_counter);
                fft_data_tlast <= '0';
                if sample_counter = 15 then
                    fft_data_tlast <= '1'; -- Last sample
                end if;
                if fft_data_tready = '1' then
                    sample_counter <= sample_counter + 1;
                end if;
            else
                fft_data_tvalid <= '0';
                fft_data_tlast <= '0';
            end if;
        end if;
    end process;

    -- Output Monitor for IFFT
    output_monitor : process(clk)
    begin
        if rising_edge(clk) then
            if ifft_output_tvalid = '1' then
                report "IFFT Output: " &
                       "Real = " & integer'image(to_integer(signed(ifft_output_tdata(31 downto 16)))) &
                       ", Imag = " & integer'image(to_integer(signed(ifft_output_tdata(15 downto 0))));
            end if;
        end if;
    end process;

end Behavioral;
