## Project Overview

### Clock Configuration

The project utilizes a **148.5 MHz clock**, generated using Vivado's Clock Wizard. This frequency is carefully chosen to meet the precise timing requirements of Full HD (1920x1080) VGA displays, ensuring accurate synchronization of the video signals and smooth refreshing of the pixels on the screen.

### Design Approach

- **VGA Signal Synchronization:** We began by generating the essential horizontal (Hsync) and vertical (Vsync) synchronization signals based on Full HD timing specifications. This ensures the monitor correctly interprets and displays the incoming video data.

- **Pixel Position Tracking:** Counters were implemented to monitor the current pixel position both horizontally and vertically. These counters enable precise control over where on the screen pixels are drawn.

- **Automated Circle Movement:** The core feature involves two circles that automatically move horizontally across the screen. Their directions reverse upon reaching the edges of the display or when the circles collide, creating a simple yet dynamic animation.

- **Interactive Vertical Control:** To add interactivity, we integrated button controls (UP and DOWN) on the Basys 3 FPGA board, allowing users to move the circles up and down vertically in real-time.

- **Visual Differentiation:** A distinct color scheme was applied to clearly distinguish the moving circles from the magenta background, improving visibility and user experience.

### Project Completion

The project culminated in a fully functional Verilog module capable of:

- Displaying **two moving circles** on a Full HD VGA screen with smooth horizontal animation and collision handling.
- Enabling **vertical position control** of the circles via physical buttons on the Basys 3 FPGA board.
- Managing all VGA synchronization signals and color outputs to ensure a crisp, flicker-free display.

This project serves as a solid foundation for expanding into more complex graphical applications and interactive FPGA-based designs.

### Demo of the video

![Demo Video](videos/video-demo.mp4)

