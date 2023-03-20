# PONG
Pong in VHDL for Digilent Nexys4 DDR FPGA board

## EXTRA FEATURES   
- After a goal is scored, the ball will wait for a while so players can get ready.    
- The ball will start each round in a different direction (going through each possibility 1 by 1) 
- Power-up: The player who loses 3 rounds in a row will be given the option to invert his opponent's controls (and also put them back to normal) with a DIP switch until he has been able to score once. This will be displayed on-screen with a green exclamation point one the side of the player who has the power-up. On the board, the LED above the corresponding DIP switch will illuminate when the power-up can be used. When the power-up is active, the opponent will see a red double arrow so they know their controls have been inverted.