turtles-own [
  my_covid_stat ; not infected (0) / infected (1) / immune (2)
  time_since_infected
  immune
  my_group
  my_risk
  my_move
  my_health_status ; healthy (0) / slightly ill (1) / severely ill (2)
  my_covid_type ; not contaminated (0) soft (1) or severe or critical (2)
  in_hospital ; no (0) / yes (1)
  wear_mask ; no (0) / yes (1)
]

globals
[ %infected
  %immune
  dead_people
  hospital_beds
  initial_hospital_beds
  initial_week_masks
  week_masks
  my_points
  dead_old_people
  cured_in_hosp
]

to go
  if ticks >= 360 [ stop ]
  if ticks mod 7 = 0 [initialize_week_masks] ; every week new masks are available for people
  if social_distancing [active_social_distancing]
  if more_masks_per_week [increase_masks_per_week]
  if more_hospital_beds [increase_hospital_beds]
  move-turtles
  ask turtles [do_you_wear_a_mask]
  contaminate
  ask turtles [do_you_go_to_hospital]
  ask turtles [do_you_die]
  ask turtles [get_older]
  update-display
  update-global-variables
  tick
end

to setup
  clear-all
  setup-turtles
  setup-variables
  reset-ticks
end

to move-turtles
  ask turtles [
    right random 360
    forward my_move
  ]
end

to setup-turtles ;creation of the population group
  create-turtles 238 [
    set shape "person"
    set color blue
    set size 1
    setxy random-xcor random-ycor
    set my_covid_stat 0
    set my_group 1
    set my_risk 0
    set my_move 3
    set my_health_status 0 ; in good shape
    set my_covid_type 0
    set in_hospital 0
  ]
    create-turtles 130 [
    set shape "person"
    set color blue
    set size 1
    setxy random-xcor random-ycor
    set my_covid_stat 0
    set my_group 2
    set my_risk 0.6
    set my_move 3
    set my_health_status 0 ; in good shape
    set my_covid_type 0
    set in_hospital 0
  ]
    create-turtles 94 [
    set shape "person"
    set color blue
    set size 1
    setxy random-xcor random-ycor
    set my_covid_stat 0
    set my_group 3
    set my_risk 4.7
    set my_move 2
    set my_health_status 0 ; in good shape
    set my_covid_type 0
    set in_hospital 0
  ]
    create-turtles 22 [
    set shape "person"
    set color blue
    set size 1
    setxy random-xcor random-ycor
    set my_covid_stat 0
    set my_group 4
    set my_risk 11.25
    set my_move 1
    set my_health_status 0 ; in good shape
    set my_covid_type 0
    set in_hospital 0
  ]
    create-turtles 236 [
    set shape "person"
    set color blue
    set size 1
    setxy random-xcor random-ycor
    set my_covid_stat 0
    set my_group 5
    set my_risk 0
    set my_move 3
    set my_health_status 0 ; in good shape
    set my_covid_type 0
    set in_hospital 0
  ]
    create-turtles 132 [
    set shape "person"
    set color blue
    set size 1
    setxy random-xcor random-ycor
    set my_covid_stat 0
    set my_group 6
    set my_risk 0.4
    set my_move 3
    set my_health_status 0 ; in good shape
    set my_covid_type 0
    set in_hospital 0
  ]
    create-turtles 108 [
    set shape "person"
    set color blue
    set size 1
    setxy random-xcor random-ycor
    set my_covid_stat 0
    set my_group 7
    set my_risk 2.8
    set my_move 2
    set my_health_status 0 ; in good shape
    set my_covid_type 0
    set in_hospital 0
  ]
    create-turtles 40 [
    set shape "person"
    set color blue
    set size 1
    setxy random-xcor random-ycor
    set my_covid_stat 0
    set my_group 8
    set my_risk 6.75
    set my_move 1
    set my_health_status 0 ; in good shape
    set my_covid_type 0
    set in_hospital 0
  ]
  ask turtles [ setxy random-xcor random-ycor ]
  ask n-of 2 turtles
    [ get-sick ]
end

to get-sick ;; turtle procedure
  set my_covid_stat 1
 ; ifelse random-float 100 < 50 [set my_covid_type 1][set my_covid_type 2]
end

to get_contaminated_without_mask  ; turtle procedure
  ; covid - people get contaminated
  if my_covid_stat = 0 [
      if random-float 100 < 80 [
    set my_covid_stat 1  ; covid status becomes yes
    set time_since_infected 0
    set my_points my_points - 1 ; -1 points at each infection
  ]]
end

to get_contaminated_with_mask ; turtle procedure
  if my_covid_stat = 0 [
      if random-float 100 < 20 [
    set my_covid_stat 1  ; covid status becomes yes
    set time_since_infected 0
    set my_points my_points - 1 ; -1 points at each infection
  ]]
end

to contaminate  ; covid+ procedure
  ask turtles [
  if my_covid_stat = 1 [
      ifelse wear_mask = 1 [
        let prey one-of turtles-here                ; grab a random person in the patch
        if prey != nobody  [                          ; did we get one? if so,
          ask prey [ get_contaminated_with_mask ]               ; contaminate the prey
          ]
      ]
      [
        let prey one-of turtles-here                ; grab a random person in the patch
        if prey != nobody  [                          ; did we get one? if so,
        ask prey [ get_contaminated_without_mask ]               ; contaminate the prey
        ]
      ]
    ]
  ]
end

to update-display
  ask turtles [
  if my_covid_stat = 0 [ set color blue ]
  if my_covid_stat = 1 [ set shape "skull" set color red set size 2]
  if my_covid_stat = 2 [ set shape "person" set color white set size 1]
  ]
end

to update-global-variables
  if count turtles > 0
    [ set %infected (count turtles with [ my_covid_stat = 1 ] / count turtles) * 100
      set dead_people (1000 - count turtles)
      set %immune (count turtles with [ my_covid_stat = 2 ] / count turtles ) * 100
      set hospital_beds (initial_hospital_beds - count turtles with [in_hospital = 1])
      ;if hospital_beds < 0 [set my_points my_points - 5] ; - 5 points per day there is no hospital bed available
      set dead_old_people (62 - count turtles with [my_group = 8] - count turtles with [my_group = 4]) ; we count people > 80 years old that are dead
  ]
end

to get_older ;; turtle procedure for disease evolution in days
  if my_covid_stat = 1 [
    set time_since_infected time_since_infected + 1
    if time_since_infected > 5 [set my_health_status 1]
    if time_since_infected > 12 [ifelse random-float 100 < 45 [set my_health_status 2][set my_health_status 1]] ; 30 to 60% of person never have severe covid
  ]

end

to do_you_die ; check if a covid infected should die
  if my_covid_stat = 1
  [
        if time_since_infected > 20
        [
            ifelse my_health_status = 2
                  [ ifelse random-float 100 < ( 100 - my_risk )   ;; either recover or die
                       [ set my_covid_stat 2
                         set my_health_status 0
                         set time_since_infected 0
                         if in_hospital = 1 [
                                    set in_hospital 0
                                    set cured_in_hosp cured_in_hosp + 3]
                         set my_points my_points + 2 ; 2 points everytime a person is cured
                       ]
                       [ if in_hospital = 1 [set in_hospital 0]
                         set my_points my_points - 100 ; - 100 points everytime a person dies
                         die    ]
                   ]
                   [ set my_covid_stat 2
                     set my_health_status 0
                     set time_since_infected 0
                     if in_hospital = 1 [set in_hospital 0]
                   ]
        ]
  ]
end

to do_you_go_to_hospital
  if hospital_beds > 0 [
    if my_health_status = 2 [
      set in_hospital 1
      set my_risk my_risk / 10 ; the risk to die of covid at hospital is divided by 10
      set hospital_beds hospital_beds - 1
    ]
  ]
end

to setup-variables
  set initial_hospital_beds 6
  set initial_week_masks 46
  set my_points 0
  set cured_in_hosp 0
end

to active_social_distancing
  ask turtles [set my_move 0.2] ; the distance a person can make is reduced to 0.2 definitely
end

to do_you_wear_a_mask
  if masks_compulsory [
  if week_masks > 0 [
    if my_health_status >= 1 [ ; only people feeling sick wear masks
      set wear_mask 1
      set week_masks week_masks - 1
    ]
  ]
    ;[set my_points my_points - 1 ] ; -1 points per person that cannot have access to a mask per day
  ]
end

to initialize_week_masks
  set week_masks initial_week_masks
end

to increase_masks_per_week
  set initial_week_masks 144
end

to increase_hospital_beds
   set initial_hospital_beds 12
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
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
1
1
1
ticks
1.0

BUTTON
64
251
127
284
start
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
63
194
126
227
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

MONITOR
697
23
768
68
NIL
%infected
3
1
11

MONITOR
865
24
950
69
total deaths
dead_people
0
1
11

MONITOR
783
24
850
69
NIL
%immune
3
1
11

PLOT
694
213
991
445
population status
NIL
NIL
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot %infected"
"pen-1" 1.0 0 -13840069 true "" "plot %immune"

MONITOR
871
165
960
210
NIL
hospital_beds
0
1
11

SWITCH
697
81
843
114
social_distancing
social_distancing
0
1
-1000

SWITCH
698
127
843
160
masks_compulsory
masks_compulsory
0
1
-1000

MONITOR
1083
123
1165
168
NIL
week_masks
0
1
11

SWITCH
873
128
1058
161
more_masks_per_week
more_masks_per_week
0
1
-1000

SWITCH
700
172
845
205
more_hospital_beds
more_hospital_beds
0
1
-1000

MONITOR
1024
212
1171
277
your total points
my_points
1
1
16

TEXTBOX
19
16
198
206
** EPIDEMY SIMULATOR **\n\nYour role is to take the right decisions at the right moment to limit the spread of the epidemy and earn the maximum health points.
12
0.0
1

MONITOR
964
25
1077
70
people >80 deads
dead_old_people
0
1
11

MONITOR
1085
25
1218
70
lives saved in hospital
cured_in_hosp
0
1
11

@#$#@#$#@
## WHAT IS IT?

The model is a Coronavirus epidemy model.
It describes the spread of the epidemy into a 1000 agent population whose demographic data is same as France.
Some parameters can be modified at set-up or during simulation to influence the spread:
- the social distancing
- the "wear a mask" policy and the number of masks available weekly
- the number of hospital beds

## HOW IT WORKS

The agents are of 8 groups : 4 age groups x 2 sex groups
they have specificities in number, in mobility and in risk factors to die of the disease.
each agent have properties such
- am I wearing a mask ?
- am I in hospital ?
- what is my health state (good health / soft symptoms / hard symptoms)
- what is my virus state (not infected / infected / immune)

a tick is a day.
Every day the following actions are performed:
- the ongoing policies are checked
- each agent moves randomly
- each agent with the virus can randomly contaminate another agent in its path (contagion factors vary function if the infected agent has a mak or not)
- each agent can decide to wear a mask if masks are available and if he has soft symptoms at least
- each agent can go to hospital if a bed is available and he fills hard symptoms
- each agent can die if it has been infected for a while, and he has hard symptoms. The propabability to die will be function of the group and the fact to be at hospital or not.
- each living agent then gets older of a day and keep its other properties


## HOW TO USE IT

to use the model you make a set-up and a start.
you can then activate the different policies of your choice (it cannot be deactivated and it is immediately applied at the next tick)

some monitors show you indicators of your population and how you manage the epidemy:
- the % of people infected
- the % of people immune
- the number of total deaths
- the number of people > 80 years old who are dead
- the number of peoples who have been saved in hospital
- the number of maks available this week
- the number of hospital beds available
- the graphic of % infected and % immune

there is also a point counter (that may be optimised)
it sums a total health score of how you managed the epidemy:
- (-1) per contamination
- (-100) per death
- (+3) per life saved in hospital
- (+2) per person immuned

## THINGS TO NOTICE

healthy persons are in blue
the infected persons are represented by red skulls
immune persons are in white

## THINGS TO TRY

play with the policies to get the highest score!

## EXTENDING THE MODEL

you are free to adjust the variables to your country demographics and to updated risk factors or contagion factors;

## NETLOGO FEATURES

-- nothing special is used in this model --

## RELATED MODELS

this model is highly based on the standard "VIRUS" model

## CREDITS AND REFERENCES

Jean MILPIED - 2020 - free to use license (please cite my name when using it in publications)
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

skull
true
15
Polygon -1 true true 135 45 75 60 60 90 60 135 60 165 90 180 90 225 150 240 210 225 210 180 240 165 240 90 225 60 165 45
Polygon -16777216 true false 105 120 105 150 120 165 135 150 135 120 105 120
Polygon -16777216 true false 165 120 165 150 180 165 195 150 195 120 165 120
Polygon -16777216 true false 150 180 135 195 165 195
Rectangle -16777216 true false 105 210 120 240
Rectangle -16777216 true false 135 225 150 255
Rectangle -16777216 true false 165 225 180 240
Rectangle -16777216 true false 195 210 210 240

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
NetLogo 6.1.1
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
