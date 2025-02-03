import random

import pandas as pd

choices = ['Rock', 'Paper', 'Scissor']
Turns = 3
ppoints = 0
cpoints = 0

while ppoints < 3 and cpoints < 3:
    CPU = random.choice(choices)
    Player = input('Please enter an option: ')
    if Player.lower() == CPU.lower():
        print('no points')
    elif Player == 'Rock' and CPU == 'Scissor':
        ppoints += 1
        print(f'CPU Points: {cpoints} and Player Points: {ppoints}')
    elif Player == 'Paper' and CPU == 'Rock':
        ppoints += 1
        print(f'CPU Points: {cpoints} and Player Points: {ppoints}')
    elif Player == 'Scissor' and CPU == 'Paper':
        ppoints += 1
        print(f'CPU Points: {cpoints} and Player Points: {ppoints}')
    else:
        cpoints += 1
        print(f'CPU Points: {cpoints} and Player Points: {ppoints}')

if ppoints == 3:
    print('Player wins!')
else:
    print('CPU Wins!')
