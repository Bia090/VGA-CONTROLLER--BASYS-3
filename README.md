# VGA Auto Circles Module

This Verilog module generates VGA signals for a Full HD (1920x1080) display. It displays two circles that move automatically on the horizontal axis and can be moved vertically using the UP and DOWN buttons on the FPGA board. The module manages VGA synchronization, pixel positioning, and color output, featuring a distinct background to highlight the circles.

## Features
- Full HD VGA signal generation (1920x1080)
- Two circles moving horizontally with automatic direction changes
- Vertical control of circles via FPGA board buttons (UP/DOWN)
- Collision detection stops horizontal movement upon contact
- Color-coded display with contrasting background

## Usage
Integrate this module into your FPGA project to add interactive VGA graphics with simple button controls.

