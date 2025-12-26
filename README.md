# Alarm System (FPGA)

Simple alarm system implemented on a Basys3 FPGA board using **VHDL** and **Vivado**.  
The system can be armed/disarmed with a code, detects incorrect entries, and provides status feedback through LEDs.

**Key functions:**
- Arming / disarming sequence (password controlled)
- Correct code → LED activation (system unlock)
- Incorrect code → alarm state (all LEDs ON)
- Debouncer module for input stability (push-buttons)
- Designed as a coursework project for *Systems with Digital Integrated Circuits* (UTCN)

Tech: VHDL, Vivado, Xilinx Basys3
