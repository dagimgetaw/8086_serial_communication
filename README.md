## 8086-8251 USART Serial Communication System

### Overview

This project demonstrates serial communication between the **8086 microprocessor** and the **8251 USART** using assembly language.  
A Proteus simulation is used with a virtual terminal for real-time input/output.

### Features

- Serial communication using 8251 USART
- ASCII input handling
- Input validation (numeric + character matching)
- Partial string verification
- Dynamic output generation
- Error handling with feedback message
- Continuous operation (infinite loop)

### How It Works

1. System initializes 8251 USART (asynchronous mode).
2. User enters a number (0–9).
3. Based on input:
   - `0` → prints full string (`HELLO WORLD`)
   - `n` → checks next `n` characters
4. If input matches → sends remaining characters
5. If mismatch → displays `" ERROR "`

### Proteus Simulation

- 8086 Microprocessor
- 8251 USART
- Virtual Terminal for I/O
- Serial communication fully simulated

### Files

- `main.asm` → Assembly program
- `serial_communication_with_8251.pdsprj` → Proteus simulation file

### Run Instructions

1. Open project in **Proteus**
2. Load assembled `.hex` file into 8086
3. Run simulation
4. Use virtual terminal to provide input

### Example

Input: 5HELLO
Output: WORLD

Input: 3ABC
Output: ERROR
