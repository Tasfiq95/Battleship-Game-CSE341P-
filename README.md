# Battleship-Game-CSE341P
Battle-Ship game using x86 assembly. 


Features:
1. 8x8 2D grid implementation: one for user to shot missile  and one in background for checking with ships placed into random slots(The background stays hidden from the player)
2. Randomized ship location: Grid with battleships generated with randomized value from BIOS clock
3. Exact Ship location with accuracy: Board with exact ship locations are showed after finishing a round
4. Dynamic score update: if missed, no points; if hit, +1 added to score and improves accuracy. Every time keeps track of previous move & displays the grid with Hit or Miss message with ‘H’/’M’!
5. Handles errors: Random ship location doesn’t disturbs the flow of the game 
6. Multiple levels:  move to level 2 regarding accuracy being 50% or higher, 15 ships in level 1 and 5 ships in level 2 (can be increased in higher levels by making less battleships in further levels, which makes it harder to guess)
7. User Defined attempt: Default attempt for guess/missile is 10, however, attempt less if wanted







