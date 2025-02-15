import numpy as np
import wfdb
import matplotlib.pyplot as plt


record = wfdb.rdrecord(rf'C:\Users\marcu\Desktop\SCS\project\scs_projecgt\scs_projecgt.srcs\resources\0001', channels=[0])
signal = record.p_signal.flatten()

fs = record.fs
fft_size = 512
time = np.arange(len(signal)) / fs 
signal_scaled = (signal / np.max(np.abs(signal)) * 32767).astype(np.int16)


plt.subplot(2, 1, 1)
plt.plot(time, signal_scaled, label="Unfiltered Int16 Signal")
plt.title("Original Int16 Signal (Unfiltered)")
plt.xlabel("Time (s)")
plt.ylabel("Amplitude (int16)")
plt.grid()
plt.legend()


plt.tight_layout()
plt.show()

hex_data = [f"0000{np.uint16(x).item():04X}" for x in signal_scaled]
with open(rf"C:\Users\marcu\Desktop\SCS\project\scs_projecgt\scs_projecgt.srcs\sim_1\imports\project\real.txt", "w") as f:
    for line in hex_data:
        f.write(line + "\n")
