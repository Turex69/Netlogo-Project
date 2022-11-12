;BEC model Salvatore Romano 1000043560
globals [
  endowment ;decides if there should be profit's growth or not
  cost-of-fighting-criminals-org ;cost of fighting criminal organization
  fighting-cost-for-state ;overall cost for the state
  cost-in-$ ;overall cost in dollar
  lorenz-points ;list of the lorenz points
]
breed [mafia a-mafious] ; criminal organization in the model called MAFIA
breed [camorra a-camorrista] ;criminal organization in the model called CAMORRA
breed [cops a-cop] ; police that control is everything is fine
breed [storeowners a-storeowner] ; people that own shops, so "profit" that the criminals want

mafia-own [ ;what features mafia owns
  money
]

cops-own [ ;what features cops own
  money
]
storeowners-own [ ;what features storeowners own
  money
]

camorra-own[ ;what features camorra owns
  money
]
patches-own [countdown]

to setup ;this button called setup will create the model's agents
  clear-all
  set cost-of-fighting-criminals-org 1000 ;initializing the value of the global variable
  set fighting-cost-for-state 0 ;initializing the value of the global variable
  set cost-in-$ "$0" ;initializing the value of the global variable
  update-lorenz ;function for the update of the lorenz curve
  ask patches [set pcolor green] ;asking to the patches to turn to green color
  if endowment? [ask patches
  [ set countdown random-exponential 360 endowment-return ;definition of the countdown of the patches
   set pcolor one-of [green red] ;randomize the pcolor with the term "one-of"
  ]
  ]

;after we will create the agents with the relevant features
set-default-shape mafia "mafious" ;this shape has been created for the mafia
create-mafia initial-number-mafious
[
  set color black
  set size 2
  set money initial-money-mafious
  setxy random-xcor random-ycor
]

set-default-shape camorra "camorra" ;this shape has been created for the camorra
  create-camorra initial-number-camorra
  [
    set size 2
    set money initial-money-camorra
    setxy random-xcor random-ycor
  ]

set-default-shape cops "cops"
create-cops initial-number-cops
[
  set color blue
  set size 2
  set money initial-money-cops
  setxy random-xcor random-ycor
]

set-default-shape storeowners "storeowner"
create-storeowners initial-number-storeowner
[
  set color white
  set size 2
  set money (random 100) + 1
  setxy random-xcor random-ycor]
;setting the endowment as profit, the patches will be green and when
;the storeowners make profits they will turn red.
set endowment count patches with [pcolor = green]
reset-ticks
end


to go
  if not any? turtles [ stop ] ; the ? cause it's a logic variable
  set fighting-cost-for-state 0 ;initializing when the button go is pressed the global variable
  update-lorenz ;call update-lorenz function
  ask storeowners [
    take-money
    multiply-storeowner ;function that reproduce the storeowners turtles, as they get profits.
    move
    death
         ]
  ask mafia [
    move
    catch-storeowners-mafia ;mafious asks for the pizzo to a storeowner.
    death
    cooperate
  ]
  ask camorra [
    move
    catch-storeowners-camorra ;camorrista asks for the pizzo to a storeowner.
    death
    cooperate
  ]
    ask cops [
    move
    catch-mafious
    catch-camorra
    ]
  set fighting-cost-for-state (fighting-cost-for-state + count turtles with [breed = mafia or breed = camorra] * cost-of-fighting-criminals-org ) ;computing the fighting cost for state
  set cost-in-$ ( word "$" fighting-cost-for-state ) ;display the overall cost
  if endowment? [ ask patches [ endowment-return ] ]
  set endowment count patches with [pcolor = green]
  tick
end


to move ;function that allows the agent to move around the world
  rt random 50
  lt random 50
  fd 1
end

to take-money ;function that spreads the money to the storeowners
  if pcolor = green [ ;color of the patches green means profit
    set pcolor red  ;no profit avalaible
    set money money + 5
  ]
end


to catch-storeowners-camorra ;the camorra wants to make profit over storeowners
  let camorra-power sum ([money] of camorra in-radius 20) / 100  ;local variable camorra-power: the more rich the camorra is in a radius of 10, the bigger its influence in the area
  let ProbRefuse-myself sum ([money] of cops in-radius 20) / 100 ;local variable ProbRefuse-myself: related to the storeowners, this variable depends on the cops resource
  let prey one-of storeowners-here ;prey will be a casual storeowner
  if prey != nobody ;condition's start
  [ask prey [ifelse (((ProbRefuse-myself  * ((storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 ))) < camorra-power ) ;checking if the prey will pay or not the pizzo
    [set money money - 2.5 ask patches in-radius 5 [endowment-return]] [set money money - 1 ask patches in-radius 2 [stop endowment-return]]]] ;based on the condition, the storeowner will give away 1 money
  ifelse (((ProbRefuse-myself * ((storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 ))) < camorra-power )
 [set money money + 2] [set money money + 0];the camorra obtains 2 coins if the storeowner pays, and anything if the storeowner refuse to pay
end



to catch-storeowners-mafia ;the mafia wants to make profit over storeowners
  let mafia-power sum ([money] of mafia in-radius 20) / 100 ;local variable mafia-power: the more rich the mafia is in a radius of 10, the bigger its influence in the area
  let ProbRefuse-myself sum ([money] of cops in-radius 20) / 100 ;local variable ProbRefuse-myself: related to the storeowners, this variable depends on the cops resource
  let prey one-of storeowners-here ;prey will be a casual storeowner
  if prey != nobody ;condition's start
  [ask prey [ifelse (((ProbRefuse-myself  * ((storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 ))) < mafia-power ) ;checking if the prey will pay or not the pizzo
     [set money money - 2.5 ask patches in-radius 5 [endowment-return]] [set money money - 1 ask patches in-radius 2 [stop endowment-return]]]] ;based on the condition, the storeowner will give away 1 money
  ifelse (((ProbRefuse-myself * ((storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 ))) < mafia-power )
 [set money money + 4] [set money money + 0];the mafia obtains 4 coins if the storeowner pays, and anything if the storeowner refuse to pay
end



to catch-camorra ;function that enable the interaction between camorra and cops
  let payment sum ([money] of camorra-here);local variable payment that a camorrista have to pay to cop
  let prey one-of camorra-here ;prey will be a casual camorrista
  if prey != nobody ;condition's start
  ;checking if the camorrista will pay or not the bribe to the cops
  ;if the answer is no, the camorra will obtain an advantage from the cops to control the market
  [ask prey [ifelse (storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 > 0 [set money money - (((storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 / 100) * payment)]
    [set money money + (((storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 / 1000) * payment)]  ]]
  ifelse (storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 > 0 [set money money + ((storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 / 100) * payment]
  [set money money + ((storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 / 1000) * payment]
end

to catch-mafious ;function that enable the interaction between mafia and cops
  let payment sum ([money] of mafia-here) ;local variable payment that a mafious have to pay to a cop
  let prey one-of mafia-here ;prey will be a casual mafious
  if prey != nobody ;condition's start
  ;checking if the mafious will pay or not the bribe to the cops
  ;if the answer is no, the mafia will obtain an advantage from the cops to control the market
  [ask prey [ifelse (storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 > 0 [set money money - (((storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 / 100) * payment)]
    [set money money + (((storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 / 1000) * payment)]  ]]
  ifelse (storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 > 0 [set money money + ((storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 / 100) * payment]
  [set money money + ((storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 / 1000) * payment]
end

to endowment-return ; this function defines the profit growth based on the cursor selection
  if pcolor = red [ ; checking the patch color, red means no profit avalaible
    ifelse countdown <= 0 ; checking the countdown in order to know if the patches color must be changed
    [set pcolor green
      set countdown endowment-rate ] ; the endowment-rate is the control of the profits' growth
   [set countdown countdown - 1 ]
  ]
end

to death ;function that allow the agents to die if they don't have money
  if money < 0 [die]
end

to multiply-storeowner ;function that allow to multiply the storeowners according to some conditions
    let mafia-power sum ([money] of mafia in-radius 10) / 1000 ; local variable mafia-power
    let camorra-power sum([money] of camorra in-radius 10) / 1000 ;local variable camorra-power
    if money > 10 and random-float 100 < storeowners-multiply ;storeowners-multiply is a slider
    ; a storeowner will expand it's business if it has the sufficient money, if the power of police linked with
    ; the global probability of refusal to pay the pizzo would be bigger than the
    ; the power of mafia (it means that the presence of mafia or camorra may reduce the willingness of new people to join in the market).
    and ((storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 / 100) > mafia-power
    and ((storeowners-thrust-in-govs-ability-to-fight-criminals * police-power) / 2 / 100) > camorra-power
    [hatch 1 rt random-float 360 fd 1 let ProbRefuse-myself sum ([money] of cops in-radius 10) / 1000] ; creation of new storeowner tutles with probability of refuse the criminal
  set money (money / 1.5)
  end

to cooperate ;function that shows the cooperation in term of money of the criminals in the interface's section
  let mafia-power sum ( [money] of mafia)
  let camorra-power sum ( [money] of camorra)
  let collab mafia-power + camorra-power
end

to update-lorenz ;function that shows the lorenz curve based on the population of the storeowners, allows to see the grade of inequality of wealth's distribution
  let storeowners-wealth  ([money] of storeowners) ;local variable storeowners-wealth
  let sorted-wealth sort storeowners-wealth ;local varibale sorted-wealth: ordering the wealth by ranking the storeowners
  let total-wealth sum sorted-wealth ;local variable total-wealth
  let wealth-sums-count 0 ;local variable wealth-sums-count: counting the wealth sum so far
  let i 0 ;local variable i: index
  let count-turtles count storeowners ;counting the storeowners
  set lorenz-points [] ;initializing the list
  repeat count-turtles[ ;computing the lorenz curve
    set wealth-sums-count (wealth-sums-count + item i sorted-wealth) ;adding to wealth-sums-count the value in the sorted-wealth index
    set lorenz-points lput ((wealth-sums-count / total-wealth) * 100) lorenz-points ;adding value in the list lorenz-points global variable
    set i (i + 1)
  ]
  let lorenzpoints-lenght length lorenz-points ;local variable lorenzpoints-lenght
end
@#$#@#$#@
GRAPHICS-WINDOW
622
10
1108
497
-1
-1
14.5
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
3
10
66
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
76
10
139
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1
252
173
285
initial-number-mafious
initial-number-mafious
0
100
13.0
1
1
NIL
HORIZONTAL

SWITCH
145
10
252
43
endowment?
endowment?
0
1
-1000

SLIDER
0
182
172
215
initial-number-cops
initial-number-cops
0
100
56.0
1
1
NIL
HORIZONTAL

SLIDER
1
217
173
250
initial-number-storeowner
initial-number-storeowner
1
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
2
45
199
78
endowment-rate
endowment-rate
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
2
80
200
113
storeowners-multiply
storeowners-multiply
0
30
11.0
1
1
NIL
HORIZONTAL

SLIDER
0
114
324
147
storeowners-thrust-in-govs-ability-to-fight-criminals
storeowners-thrust-in-govs-ability-to-fight-criminals
0
10
0.0
1
1
NIL
HORIZONTAL

PLOT
323
11
624
220
Storeowners' Population
Time
Storeowners
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Storeowners" 1.0 0 -14730904 true "" "plot count storeowners"

SLIDER
0
348
172
381
initial-money-mafious
initial-money-mafious
1
50
50.0
1
1
NIL
HORIZONTAL

SLIDER
0
316
172
349
initial-money-cops
initial-money-cops
1
50
30.0
1
1
NIL
HORIZONTAL

PLOT
231
219
624
395
Money Flow
Time
Money
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Mafious" 1.0 0 -987046 true "" "plot sum [money] of mafia"
"Police" 1.0 0 -5825686 true "" "plot sum [money] of cops"
"Storeowners" 1.0 0 -13210332 true "" "plot sum [money] of storeowners"
"Camorra" 1.0 0 -7500403 true "" "plot sum [money] of camorra"

SLIDER
0
149
174
182
police-power
police-power
-10
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
1
283
172
316
initial-number-camorra
initial-number-camorra
0
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
0
379
173
412
initial-money-camorra
initial-money-camorra
1
50
50.0
1
1
NIL
HORIZONTAL

PLOT
1108
10
1390
160
Money of mafia and camorra
Time 
Money
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -5825686 true "" "  let mafia-power sum ( [money] of mafia)\n  let camorra-power sum ( [money] of camorra)\n     plot mafia-power + camorra-power\n  "

PLOT
1108
160
1390
312
Government's cost to fight criminals
Time
NIL
0.0
2.0
0.0
2.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" "plot fighting-cost-for-state"

MONITOR
1140
311
1355
356
Governmenet's cost to fight criminals
cost-in-$
6
1
11

MONITOR
486
394
624
439
Criminals in the world
count turtles with [ breed = mafia or breed = camorra ]
17
1
11

MONITOR
231
394
363
439
Mafia's money
(word \"$ \" (precision (sum [money] of mafia) 2) )
6
1
11

MONITOR
363
394
486
439
Camorra's money
(word \"$ \" (precision (sum [money] of camorra) 2) )
2
1
11

PLOT
1110
357
1394
538
Lorenz curve
Storeowners
Wealth
0.0
100.0
0.0
100.0
false
false
"" ""
PENS
"pen-1" 100.0 0 -16777216 true "plot 0 plot 100" ""
"lorez" 1.0 0 -2674135 true "" "plot-pen-reset\nset-plot-pen-interval 100 / count storeowners\nplot 0\nforeach lorenz-points plot"

@#$#@#$#@
## WHAT IS IT?

This model intends to simulate the interaction of a mafia-based economy. 
Resources spent on the police and social norms by the government will affect the outcome
of black wealth.

## HOW IT WORKS

The market will grow profit according to the endowment-rate, green patches indicates profit obtainable for storeowners. Red patches have no profit.
Mafious wants to make interactions with storeowners to increase their power. Storeowners will pay them regarding several social factors.
The Police interact with mafious, either the mafia has to pay a bribe, or the police will
help the mafia in controlling the market.

## HOW TO USE IT

First of all, you should adjust the sliders and the switch according to the state of the world you wish to simulate. 
Then press the setup button to create this initial state of the world. 
To run the model, and begin all the interactions in the model, press the go-button.
As time goes, you can look at the different monitors to observe money flow, black wealth and the population of the storeowners.

Endowment? decides if there should be growth of profit or not
Endowment-rate decides the growth of profit in the market
Storeowners-multiply decides the limit of profit for a storeowner to give birth to a new storeowner. This can mean that he's expanding his business.
storeowners-thrust-in-govs-ability-to-fight-mafia gives its own explanation. Changes in public interventions which will affect short-term norms will induce changes in this one.
Police-power captures the governments abilites to fight against the mafia.


## THINGS TO NOTICE

The core of the strength of public interventions applied to social norms, is that it's able to increase the efficiency of the economy, by changing behavior. By changing the slider storeowners-thrust-in-govs-ability-to-fight-mafia for a small amount of time, a benchmark for social norms may be reached so that the government may get long-term 
beneficial effects regarding behavior and black wealth, even when the slider storeowners-thrust-in-govs-ability-to-fight-mafia returns to its initial position.

## THINGS TO TRY

Try to find the benchmarks for making long-term beneficial effects in black wealt by doing some short-term public intervention, by changing storeowners-thrust-in-govs-ability-to-fight-mafia for a short amount of time.

## EXTENDING THE MODEL

The relationship between the variables could be estimated and implemented in the model to make it more realistic, as a part of the syntax or as a slider according to uncertainty. The interaction between the agents could be more complex, storeowners could affect each other, police could have interacted with the storeowners to check if their business was legal. The public interventions affecting social norms, here through storeowners-thrust-in-govs-ability-to-fight-mafia, could be separated into different types of expenditures in public interventions, norms management, regulations, financial interventions and changing architecture, to make it more suitable for real life. Then the storeowners propensinsity to adapt these norms could be adjusted by a slider, to simulate different network structures and societies.

## Related models

"Mafianomics" http://web.econ.unito.it/terna/tesine/mafianomics.htm
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

camorra
false
4
Circle -16777216 true false 105 0 90
Polygon -8630108 true false 105 90 135 135 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 135 195 90
Rectangle -16777216 true false 127 79 172 94
Polygon -16777216 true false 195 90 240 150 225 180 165 105
Polygon -16777216 true false 105 90 60 150 75 180 135 105
Rectangle -7500403 true false 225 120 225 135
Rectangle -7500403 true false 240 150 225 135
Polygon -16777216 true false 225 135 225 150 225 105 270 105 270 120 240 120 240 150 225 135

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cops
false
0
Circle -13345367 true false 110 5 80
Polygon -13345367 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -13345367 true false 127 79 172 94
Polygon -13345367 true false 195 90 240 150 225 180 165 105
Polygon -13345367 true false 105 90 45 90 30 135 135 105
Polygon -13345367 true false 105 45 75 45 120 0 195 0 210 45

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

mafious
false
0
Circle -16777216 true false 110 5 80
Polygon -16777216 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -16777216 true false 127 79 172 94
Polygon -16777216 true false 195 90 240 150 225 180 165 105
Polygon -16777216 true false 105 90 60 150 75 180 135 105
Rectangle -7500403 true true 225 120 225 135
Rectangle -7500403 true true 240 150 225 135
Polygon -16777216 true false 225 135 225 150 225 105 270 105 270 120 240 120 240 150 225 135

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

storeowner
false
0
Circle -1 true false 110 5 80
Polygon -1 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -1 true false 127 79 172 94
Polygon -1 true false 195 90 240 150 225 180 165 105
Polygon -1 true false 105 90 60 150 75 180 135 105

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
