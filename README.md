# FPGA Experiments
Practice projects for the Basys3 Artix-7 board

## StopWatch
1. Set a time by incrementing seconds using the up/down buttons
2. Display the time using the 7-segment display
3. Countdown the time
4. Signal end of countdown by flashing LEDs

### TODO
 - [X] Debounce buttons
 - [X] Add counter for buttons
 - [X] Display integers on 7-Segment display
 - [X] Add LED flashing sequence
 - [X] Add reset signal
 - [X] Tidy

## UART Peak Detector
1. Send data over UART from host -> FPGA
2. Calculate the peak value of the data
3. Send the peak value back to the host

### TODO
- [X] Add UART Receiver
- [X] Add UART Transmitter
- [X] Add peak detection logic
