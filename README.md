# PONG
Pong in VHDL for Digilent Nexys4 DDR FPGA board. Developed for a digital electronics course at the University of Antwerp. **(Grade: 15/20)**

## EXTRA FEATURES   
- After a goal is scored, the ball will wait for a while so players can get ready.    
- The ball will start each round in a different direction (going through each possibility in a round-robin fashion) 
- Power-up: The player who loses 3 rounds in a row will be given the option to invert his opponent's controls (and also put them back to normal) with a DIP switch until they have been able to score once. This will be displayed on-screen with a green exclamation point on the side of the player who has the power-up. On the board, the LED above the corresponding DIP switch will illuminate when the power-up can be used. When the power-up is active, the opponent will see a red double-sided arrow so they know their controls have been inverted.
