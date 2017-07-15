local chatdown=require("wetgenes.gamecake.fun.chatdown")
local bitdown=require("wetgenes.gamecake.fun.bitdown")
local chipmunk=require("wetgenes.chipmunk")


hardware,main=system.configurator({
	mode="fun64", -- select the standard 320x240 screen using the swanky32 palette.
	graphics=function() return graphics end,
	update=function() update() end, -- called repeatedly to update+draw
})

-- debug text dump
local ls=function(t) print(require("wetgenes.string").dump(t)) end


local chat_text=[[

#npc1 Conversation NPC1

	A rare bread of NPC who will fulfil all your conversational desires for 
	a very good price.

	=sir sir/madam

	>convo

		Do you have information?
		
	>exit
	
		Bye, bye

<welcome

	Good Morning {lord},
	
	>morning

		Good morning to you too.

	>afternoon

		I think you will find it is now afternoon.

	>sir

		How dare you call me {lord}!

<sir

	My apologies, I am afraid that I am but an NPC with very little 
	brain, how might I address you?
	
	>welcome.1?sir!=madam

		You may address me as lady.

		=sir madam

	>welcome.2?sir!=God

		You may address me as God.

		=sir God

	>welcome.3?sir!=sir

		You may address me as Sir.

		=sir sir

<afternoon
	
	Then good afternoon {sir},
	
	>convo

<morning
	
	and how may I help {lord} today?
	
	>convo


<convo

	Indeed I do, would you like the full information or just the quick natter?

	>convo_full
	
		How long is the full information?

	>convo_quick

		A quick natter sounds just perfect.

<convo_full

	The full informationtion is very full and long so much so that you 
	will listen for along time in the breafing
	
	>
		Like this?
	<
	
	Yes just like this. In fact I think you can see that we are already 
	starting it.
			
	
	>exit

<convo_quick

	...
	
	>exit

#npc2 Conversation NPC2

	Not a real boy.

<welcome

	Sorry but I have no information.
	
	>exit
	
		Bye bye.


#npc3 Conversation NPC3

	Not a real girl.

<welcome

	Sorry but I have no information.
	
	>exit
	
		Bye bye.


#npc4 Conversation NPC4

	Not a real girl.

<welcome

	I forged your blade.
	
	>exit
	
		Bye bye.


#npc5 Conversation NPC5

	Not a real girl.

<welcome

	I am a sorceress.
	
	>exit
	
		Bye bye.

#npc6 Conversation NPC6

	Not a real girl.

<welcome

	Who are you to question me?
	
	>exit
	
		Bye bye.

]]


-- define all graphics in this global, we will convert and upload to tiles at setup
-- although you can change tiles during a game, we try and only upload graphics
-- during initial setup so we have a nice looking sprite sheet to be edited by artists

graphics={
{0x0000,"_font",0x0140}, -- allocate the font area
{nil,"char_empty",[[
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
]]},
{nil,"char_black",[[
0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 
]]},
{nil,"char_wall",[[
O O R R R R O O 
O O R R R R O O 
r r r r o o o o 
r r r r o o o o 
R R O O O O R R 
R R O O O O R R 
o o o o r r r r 
o o o o r r r r 
]]},
{nil,"char_floor",[[
j j j j j j j j j j j j j j j j j f f f f f f f f j j j j j j j j j j j j j j j 
f f f F F F F f f f f f f f f f f F F F F F F F F f f f f f f j j j j j f f f f 
F F F f f f f F F F F F F F F F F f f f f f f f f F F F F F F f f f f f F F F F 
f f f f f f f f f f F F F F f f f f f f f f f f f f f f f f f F F F F F f f f f 
f f f j j j j f f f f f f f f f f j j j j j j j j f f f f f f f f f f f f f f f 
j j j f f f f j j j f f f f j j j f f f f f f f f j j j j j j f f f f f j j j j 
f f f j j j j f f f j j j j f f f j j j j j j j j f f f f f f j j j j j f f f f 
j j j j j j j j j j j j j j j j j j j j j j j j j j j j j j j j j j j j j j j j 
]]},
{nil,"char_bomb",[[
. . . . 7 7 Y Y
. . . 7 7 . . .
. . . 2 . . . .
. . 0 0 0 . . .
. 0 0 0 0 0 . .
. 0 0 0 0 0 . .
. 0 0 0 0 0 . .
. . 0 0 0 . . .
]]},
{nil,"char_ammo",[[
. . . y y y y . . . . F F F . . 
. . y y y y y . . . F . 3 . F . 
. . y y y y . . . F 7 7 7 7 7 F 
. . 0 0 0 0 . . . . . . . . . . 
. y y y y y y . . . . . . . . . 
. y y y y y y F 6 6 6 F . . 6 . 
. y y y y y y . F . F . O O 6 O 
. y y y y y y . . F . . . . 6 . 
]]},
{nil,"player_f1",[[
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . 4 4 4 4 . . . . . . . . . . 
. . . . . . . . . 4 2 R R 1 4 . . . . . . . . . 
. . . . . . . . . 4 R 2 1 R 4 . . . . . . . . . 
. . . . . . . . 4 R R 1 2 R R 4 . . . . . . . . 
. . . . . . . 4 R R 1 R R 2 R R 4 . . . . . . . 
. . . . . . . 4 4 4 4 4 4 4 4 4 4 . . . . . . . 
. . . . . . . . . . S S 0 S . . . . . . . . . . 
. . . . . . . . . . S S S S S . . . . . . . . . 
. . . . . . . . . . S S S S . . . . . . . . . . 
. . . . . . . . . . . S S . . . . . . . . . . . 
. . . . . . . . . . R S R 7 . . . . . . . . . . 
. . . . . . . . . 7 R 7 R 7 R . . . . . . . . . 
. . . . . . . . . 7 R 7 R 7 R . . . . . . . . . 
. . . . . . . . R 7 R 7 . 7 R 7 . C . . . . . . 
. . . . . . . . R 7 R 7 R . R 7 Y C Y Y Y Y . . 
. . . . . . . . . . 7 7 7 7 . . . C . . . . . . 
. . . . . . . . . 7 7 7 . 7 7 . . . . . . . . . 
. . . . . . . . . 7 7 . 7 7 7 . . . . . . . . . 
. . . . . . . . . 7 7 7 . 7 7 7 . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
]]},
{nil,"player_f2",[[
. . . . . . . . . . . . . . . . . . . . . . . .
. . . . . . . . . . 4 4 4 4 . . . . . . . . . . 
. . . . . . . . . 4 2 R R 1 4 . . . . . . . . . 
. . . . . . . . . 4 R 2 1 R 4 . . . . . . . . . 
. . . . . . . . 4 R R 1 2 R R 4 . . . . . . . . 
. . . . . . . 4 R R 1 R R 2 R R 4 . . . . . . . 
. . . . . . . 4 4 4 4 4 4 4 4 4 4 . . . . . . . 
. . . . . . . . . . S S 0 S . . . . . . . . . .
. . . . . . . . . . S S S S S . . . . . . . . .
. . . . . . . . . . S S S S . . . . . . . . . . 
. . . . . . . . . . . S S . . . . . . . . . . . 
. . . . . . . . . . R 7 R 7 R . . . . . . . . .  
. . . . . . . . . R 7 R 7 R 7 . . . . . . . . . 
. . . . . . . . . R 7 R 7 R 7 . . . . . . . . .
. . . . . . . . . R 7 R 7 R 7 . C . . . . . . .
. . . . . . . . . R 7 R R R 7 Y C Y Y Y Y . . . 
. . . . . . . . . . 7 R 7 . . . C . . . . . . .
. . . . . . . . . . . 7 7 . . . . . . . . . . .
. . . . . . . . . . . 7 7 . . . . . . . . . . . 
. . . . . . . . . . . 7 7 7 . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . . . . . . .  
. . . . . . . . . . . . . . . . . . . . . . . .  
. . . . . . . . . . . . . . . . . . . . . . . .  
 . 
]]},
{nil,"player_f3",[[
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . 4 4 4 4 . . . . . . . . . . 
. . . . . . . . . 4 2 R R 1 4 . . . . . . . . . 
. . . . . . . . . 4 R 2 1 R 4 . . . . . . . . . 
. . . . . . . . 4 R R 1 2 R R 4 . . . . . . . . 
. . . . . . . 4 R R 1 R R 2 R R 4 . . . . . . . 
. . . . . . . 4 4 4 4 4 4 4 4 4 4 . . . . . . . 
. . . . . . . . . . S S 0 S . . . . . . . . . . 
. . . . . . . . . . S S S S S . . . . . . . . . 
. . . . . . . . . . S S S S . . . . . . . . . . 
. . . . . . . . . . . S S . . . . . . . . . . . 
. . . . . . . . . . 7 R 7 R . . . . . . . . . . 
. . . . . . . . . R 7 R 7 R 7 . . . . . . . . . 
. . . . . . . . 7 R 7 R 7 R 7 R . . . . . . . . 
. . . . . . . R 7 R 7 R 7 R 7 R 7 . C . . . . . 
. . . . . . . R 7 . 7 R 7 R . R 7 Y C Y Y Y Y . 
. . . . . . . . . . 7 7 7 7 7 . . . C . . . . . 
. . . . . . . . . 7 7 7 . 7 7 . 7 . . . . . . . 
. . . . . . . . 7 7 . . . . 7 7 7 . . . . . . . 
. . . . . . . . 7 7 7 . . . 7 7 . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
]]},
{nil,"cannon_ball",[[
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . 0 0 0 0 . . . . . . . . . . 
. . . . . . . 0 0 0 0 0 0 0 0 0 0 . . . . . . . 
. . . . . . 0 0 0 F F 0 0 0 0 0 0 0 . . . . . . 
. . . . . 0 0 0 0 F F F 0 F 0 F 0 0 0 . . . . . 
. . . . . 0 0 0 0 0 0 0 0 0 0 0 0 0 0 . . . . . 
. . . . . 0 0 0 0 0 0 0 0 0 0 0 0 0 0 . . . . . 
. . . . 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 . . . . 
. . . . 0 0 0 0 0 0 0 1 1 0 0 F 0 0 0 0 . . . . 
. . . . 0 0 0 0 0 F 0 1 1 0 0 0 0 0 0 0 . . . . 
. . . . 0 0 0 0 0 0 0 F 0 0 0 0 0 0 0 0 . . . . 
. . . . . 0 0 0 0 0 0 0 0 0 0 0 0 0 0 . . . . . 
. . . . . 0 0 0 0 0 0 0 0 0 0 0 0 0 0 . . . . . 
. . . . . 0 0 0 0 0 F 0 0 0 0 0 0 0 0 . . . . . 
. . . . . . 0 0 0 0 0 0 0 F 0 0 0 0 . . . . . . 
. . . . . . . 0 0 0 0 0 0 F 0 0 0 . . . . . . . 
. . . . . . . . . . 0 0 0 0 . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
 
]]},
{nil,"coin",[[
. . . . . . . . 
. . Y Y Y Y . . 
. Y Y 0 0 Y Y . 
Y Y 0 Y Y 0 Y Y 
Y Y Y 0 0 Y Y Y 
Y Y 0 Y Y 0 Y Y 
. Y Y 0 0 Y Y . 
. . Y Y Y Y . . 
]]},


{nil,"npc1",[[
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . R R R R R . . . . . . . . 
. . . . . . . . . . R R R R R R R . . . . . . . 
. . . . . . . . . . R R R R R R R . . . . . . . 
. . . . . . . . . . . Y 0 Y Y R R . . . . . . . 
. . . . . . . . . . M Y m m Y R R . . . . . . . 
. 7 . . . . . . . . . 2 2 2 2 . R . R . . . . . 
. 7 . . . . . . . . . . 2 2 . . . R . . . . . . 
7 7 7 . . . . . . . . 2 b b 2 . . . . . . . . . 
. 7 7 . . . . . . . 2 b b b b 2 . . . . . . . . 
. . . 7 . . . . . . 2 b b b b 2 . . . . . . . . 
. . . . 7 . . . . 2 2 b b b b 2 2 . F . . . . . 
. . . . . 7 7 7 7 2 2 b b b b 2 2 7 F 7 7 7 7 . 
. . . . . . . . . . . b b b b . . . F . . . . . 
. . . . . . . . . . 2 I . 2 2 I . . . . . . . . 
. . . . . . . . . . 2 I I . 2 I . . . . . . . . 
. . . . . . . . . I I I . I I I . . . . . . . . 
]]},

{nil,"npc2",[[
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . I I I . . . . . . . . . . 
. . . . . . . . . . I I I I I . . . . . . . . . 
. . . . . . . . . I I I I I I I . . . . . . . . 
. . . . . . . b b b b b b b b b . . . . . . . . 
. . . . . . . . . j j j j j j j . . . . . . . . 
. . . . . . . . . . s 0 s j j j . . . . . . . . 
. . . . . . . . . M s s s s j . . . . . . . . . 
. . . . . . . . . . s s s s . . . . . . . . . . 
. . . . . 2 . . . . . s s . . . . . . . . . . . 
. . . . 2 2 2 F . . 4 G G 4 . . . . . . . . . . 
. . . . 2 2 2 F . 4 G G G G 4 . . . . . . . . . 
. . . . . 2 . F . 4 G G G G 4 . . . . . . . . . 
. . . . . . . F 3 3 G G G G 3 3 . . 5 . . . . . 
. . . . . . . F 3 3 2 2 2 2 3 3 O O 5 O O O O . 
. . . . . . . . . 2 2 2 2 2 . . . . 5 . . . . . 
. . . . . . . . . 7 7 . 7 7 B . . . . . . . . . 
. . . . . . . . . 5 5 B . 5 B . . . . . . . . . 
. . . . . . . . B B B . B B B . . . . . . . . . 
]]},

{nil,"npc3",[[
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . o o . . . . . . . . . . 
. . . . . . . . . . o o o o o . . . . . . . . . 
. . . . . . . . o o o o o o o o . . . . . . . . 
. . . . . . . . . o o 1 1 o o o . . . . . . . . 
. . . . . . . . . . 1 0 1 1 o o . . . . . . . . 
. . . . . . . . . 1 1 m m 1 1 o . . . . . . . . 
. . . . . . . . . . 1 1 1 1 o o . . . . . . . . 
. . . . . . . . . . . 1 1 . o o . . . . . . . . 
. . . . . . . . . . j 1 1 j . . . . . . . . . . 
. . . . . . . . . 1 f j j f 1 o 7 7 7 o . . . . 
. . . . . . O . . 1 j j j j 1 . o . o . . . . . 
. . 5 5 5 5 O F 1 1 j j j j 1 1 . o . . . . . . 
. . . . . . O . 1 1 j j j j 1 1 1 o . . . . . . 
. . . . . . . . . . g g g g . . . o . . . . . . 
. . . . . . . . . g g . g g d . o o o . . . . . 
. . . . . . . . . g g d . g d . o o o . . . . . 
. . . . . . . . d d d . d d d . o o o . . . . . 

]]},

{nil,"npc4",[[
. . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . 3 3 3 3 3 3 . . . . . . . . . . 
. . . . . . . . . . D D D D 3 . . . . . . . . . . 
. . . . . . . . . D D D 0 D 3 . . . . . . . . . . 
. . 2 2 2 2 2 . D D D m m D 3 . . . . . . . . . . 
. . 2 2 2 2 2 . D D D D D D 3 . . . . . . . . . . 
. . . . F . . . . D D D D D 3 . . . . . . . . . . 
. . . . F . . . . . 3 D D 3 3 . . . . . . . . . . 
. . . . F . . . 3 3 f 3 3 f 3 3 . . . . . . . . . 
. . . . F . . 3 3 3 3 3 3 3 3 3 3 . . . . . . . . 
. . . . F 3 3 3 . . 3 3 3 3 . . 3 3 3 . . . . . . 
. . . . . . . . . . 3 3 3 3 . . . . . . . . . . . 
. . . . . . . . . . g g g g . . . . . . . . . . . 
. . . . . . . . . g g . g g d . . . . . . . . . . 
. . . . . . . . . g g d . g d . . . . . . . . . . 
. . . . . . . . d d d . d d d . . . . . . . . . . 


]]},

{nil,"npc5",[[
. . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . j j j j . . . . . . . 
. . . . . . . . . . . S S j j . . . . . . . 
. . . . . . . . . . S 0 S S j . . . . . . . 
. . . . . . . . . . S S S S j . . . . . . . 
. . . . . . . . . . S S S S j . . d d . . . 
. . f f . . . . j j . S S . j j . d d . . . 
. Y Y Y . . . . j j j j j j j j . . . . . . 
. . f f j j j j j . j j j j . j j j j . . . 
. . f f j j j . . . j j j j . . . j j . . . 
. f f f f . . . . . j j j j . . . . . . . . 
. f f f f . . . . . j j j j . . . . . . . . 
. f f f f . . . . . j j j j . . . . . . . . 
. f f f f . . . . . j j j j . . . . . . . . 
. . . . . . . . j j j j j j j . . . . . . . 
. . . . . . . . j j j j j j j j . . . . . . 
. . . . . . . j j j j j j j j j . . . . . . 
. . . . . . j j j j j j j j j j j . . . . . 
. . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . 


]]},

{nil,"npc6",[[
. Y . . . . . Y . Y . Y . Y . Y . . . . . . 
R R R . . . . Y Y c I R g O Y Y . . . . . . 
O O O . . . . . . r r r r r r . . . . O . . 
Y Y Y . . . . . . r . . r r r . . . . Y . . 
R R R . . . . . . r r r r r r . . . . O . . 
Y Y Y . . . . . . r r r r r r . . . Y Y Y . 
O O O . . . . . . r r r r r r . . . R R R . 
R R R . . . . R . r r r r r r . R . O O O . 
Y Y Y . . . . R R R R R R R R R R . . . . . 
. Y . . . R R R R R R R R R R R R R R . . . 
. Y . R R R . R R O O O O O O R R . R R R . 
. Y R R . . . R R O Y Y Y Y O R R . . . R R 
Y Y Y . . . . R R O Y Y Y Y O R R . . . . . 
. . . . . . . R R O O O O O O R R . . . . . 
. . . . . . . R R R R R R R R R R . . . . . 
. . . . . . . R R R R R R R R R R . . . . . 
. . . . . . . . f f . . . . f f . . . . . . 
. . . . . . . . f f . . . . f f . . . . . . 
. . . . . . . . f f . . . . f f . . . . . . 
. . . . . . . . f f . . . . f f . . . . . . 
. . . . . . . . f f . . . . f f . . . . . . 
. . . . . . . . f f . . . . f f . . . . . . 
. . . . . . . . f f . . . . f f . . . . . . 
. . . . . . . . f f . . . . f f . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . 


]]},


{nil,"char_bigwall",[[
I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I 
I . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . I 
I . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . I 
I . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . I 
I . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . I 
I . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . I 
I . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . I 
I . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . I 
I . . . . . . . . . . . . . . . . . d d d d d d d d . . . . . . . . . . . . . I 
I . . . . . . . . . . . . . . . . g d d d d d d d d g . . . . . . . . . . . . I 
I . . . . . . . . . . . . . . . . g d d d d d d d d g . . . . . . . . . . . . I 
I . . . . . . . . . . . . . . . . g d d d d d d d d g . . . . . . . . . . . . I 
I . . . . . . . . . . . . . . . . g d d d d d d d d g . . . . . . . . . . . . I 
I . . . . . . . . . . . . . . . . g d d d d d d d d g . . . . . . . . . . . . I 
I . . . . . . . . . . . . . . . . g d d d d d d d d g . . . . . . . . . . . . I 
I . . . . . . . . . . . . . . . . g g g g g g g g g g . . . . . . . . . . . . I 
]]},

{nil,"char_grass",[[
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. R R . . R R . . R R . . R R . . R R . . R R . R R . . R R . . R 
R R R R R R R R R R R R R R R R R R R R R R R R R R R R R R R R R 
R R R R R R R R R R R R R R R R R R R R R R R R R R R R R R R R R 
. R R . . R R . . R R . . R R . . R R . . R R . R R . . R R . . R 

]]},

{nil,"char_stump",[[
. . m 7 7 m . . 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
m m m 7 7 m m m 
]]},

{nil,"char_sidewood",[[
F S S S S S S F 
F S S S S S S F 
F S S S S S S F 
F S S S S S S F 
F S S S S S S F 
F S S S S S S F 
F S S S S S S F 
F S S S S S S F 
]]},

{nil,"char_tree",[[
. . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . 
. . . . . . . . R j . . . . . . 
. . . j . . . . . j . . . . . . 
. . R . f . . . j . R . . . . . 
. . . . f F . j . . . . . . . . 
. . . . . f F j R . j . . . . . 
. . . . . j f F . f . R . . . . 
. . . . . . . f . j . . . . . . 
. . . . . . . f F f . . . . . . 
. . . . . j F f f f . . . . . . 
. . . . R . f F j f . . . . . . 
. . . . . . j F j f . . . . . . 
. . . . . . j f j f . . . . . . 
. . . . . . j F j f . . . . . . 
. . . . . . j f f f . . . . . . 
. . . . . . j f f f . . . . . . 
. . . . . . j f f f . . . . . . 
. . . . . . j f f f . . . . . . 
. . . . . . j F f f . . . . . . 
. . . . . . j F f f . . . . . . 
. . . . . . j f f f . . . . . . 
. . . . . . j f f f . . . . . . 
. d d d d d j F F F . . . . . . 
]]},

{nil,"char_pidestal",[[
. . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . 
. 2 2 2 2 2 2 2 2 2 2 2 2 2 . . 
. 2 d d 2 Y Y 2 7 7 2 j j 2 . . 
. 2 2 2 2 2 2 2 2 2 2 2 2 2 . . 
. 2 2 2 2 2 2 2 2 2 2 2 2 2 . . 
]]},

{nil,"char_sign",[[
02020202020202020200000000000000
02020202020202020202000000000000
02020202020202020202000000020202
02020202020202020202020000020202
02020202020202020202020002020202
02020202020202020202020002020202
02020202020202020202020202020202
02020202020202020202020000020202
02020202020202020202000000020202
02020202020202020202020000020202
0202020202020202020202000C0C0C0C
000C0C0C0C000C0C0C0C0C000C0C0C0C
000C0C0C00000C0C0C0C0000000C0C0C
000C0C0C00000C0C0C0C0000000C0C0C
0C0C0C0C00000C0C0C0C0000000C0C0C
000C0C0C00000C0C0C0C0000000C0C0C
]]},
}



local combine_legends=function(...)
	local legend={}
	for _,t in ipairs{...} do -- merge all
		for n,v in pairs(t) do -- shallow copy, right side values overwrite left
			legend[n]=v
		end
	end
	return legend
end

local default_legend={
	[0]={ name="char_empty",	},

	[". "]={ name="char_empty",				},
	["00"]={ name="char_black",				solid=1, dense=1, },		-- black border
	["0 "]={ name="char_empty",				solid=1, dense=1, },		-- empty border

	["||"]={ name="char_sidewood",				solid=1},				-- wall
	["=="]={ name="char_floor",				solid=1},				-- floor

-- items not tiles, so display tile 0 and we will add a sprite for display
	["S "]={ name="char_empty",	start=1,	},
	["N1"]={ name="char_empty",	npc="npc1",				sprite="npc1", },
	["N2"]={ name="char_empty",	npc="npc2",				sprite="npc2", },
	["N3"]={ name="char_empty",	npc="npc3",				sprite="npc3", },
        ["N4"]={ name="char_empty",	npc="npc4",				sprite="npc4", },
        ["N5"]={ name="char_empty",	npc="npc5",				sprite="npc5", },
        ["N6"]={ name="char_empty",	npc="npc6",				sprite="npc6", },
	["WW"]={ name="char_bigwall", solid=1, },
	[",,"]={ name="char_grass", },
	["t."]={ name="char_tree", solid=1,  },
	["S="]={ name="char_stump", solid=1, },
	["s."]={ name="char_sign", solid=1, },
        ["B."]={ name="char_bomb", solid=1, },
        ["A."]={ name="char_ammo", },
        ["P."]={ name="char_pidestal", },
}
levels={}

levels[1]={
legend=combine_legends(default_legend,{
	["?0"]={ name="char_empty" },
}),
title="This is a test.",
map=[[
||0000000000000000000000000000000000000000000000000000000000000000000000000000||
||. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ||
||. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ||
||. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ||
||. . . . . . . . . t.t.. . . . . . . . . . . . . . . . . . . . . . . . . . . ||
||. . . . . . N6. . t.t.. . . . . . . s.s.. . . . . . . . . . . . . N3. . . . ||
||. . . . . . . . . t.t.. . . . . . . s.s.. . . . . . . . . . . . . . . . . . ||
||================================================. . . . ====================||
||. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ||
||. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ||
||======. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ||
||. N4. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ||
||. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ||
||==========. . . . . . . . . . t.t.. . . . . . . N2N3. . . . . . . . . . . . ||
||. . . . . . . . . . . . . . . t.t.. . . . N5. WWWWWWWWWWWW. . . . N2. N2. N2||
||. . . A.A.. . . . . . . . . . t.t.. . . . . . WWWWWWWWWWWWB. . . . . . . .  ||
||==============. . . . ======================================================||
||. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ||
||. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ||
||==. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ||
||. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ||
||. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . N1. . ||
||==. . . . . . . . . . . . . . . . . . . . . . S=. . . . . . . . . . . . . . ||
||. . . . . . . . . . . . . . . . . . . S=. . . S=. . . . . . . ==============||
||. . . S . . . ,,,,,,S=S=S=,,,,,,,,,,,,S=,,,,,,S=,,,,,,,,,,,,,,,,,,. . . . . ||
||==. . . . . . ====================================================. . . . . ||
||. . . . . . . . . . N5. . . . . . . . N5. . . . . . . . . . N4. . P.P.P.P.. ||
||. . . . . . . . . . . . A.A.. A.A.. ==. . . A.A.A.A.A.A.A.. . . . P.P.P.P.. ||
||============================================================================||
||0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ||
]],
}


-- handle tables of entities that need to be updated and drawn.

local entities -- a place to store everything that needs to be updated
local entities_info -- a place to store options or values
local entities_reset=function()
	entities={}
	entities_info={}
end
-- get items for the given caste
local entities_items=function(caste)
	caste=caste or "generic"
	if not entities[caste] then entities[caste]={} end -- create on use
	return entities[caste]
end
-- add an item to this caste
local entities_add=function(it,caste)
	caste=caste or it.caste -- probably from item
	caste=caste or "generic"
	local items=entities_items(caste)
	items[ #items+1 ]=it -- add to end of array
	return it
end
-- call this functions on all items in every caste
local entities_call=function(fname,...)
	local count=0
	for caste,items in pairs(entities) do
		for idx=#items,1,-1 do -- call backwards so item can remove self
			local it=items[idx]
			if it[fname] then
				it[fname](it,...)
				count=count+1
			end
		end			
	end
	return count -- number of items called
end
-- get/set info associated with this entities
local entities_get=function(name)       return entities_info[name]							end
local entities_set=function(name,value)        entities_info[name]=value	return value	end
local entities_manifest=function(name)
	if not entities_info[name] then entities_info[name]={} end -- create empty
	return entities_info[name]
end
-- reset the entities
entities_reset()


-- call coroutine with traceback on error
local coroutine_resume_and_report_errors=function(co,...)
	local a,b=coroutine.resume(co,...)
	if a then return a,b end -- no error
	error( b.."\nin coroutine\n"..debug.traceback(co) , 2 ) -- error
end


-- create space and handlers
function setup_space()

	local space=entities_set("space", chipmunk.space() )
	
	space:gravity(0,700)
	space:damping(0.5)
	space:sleep_time_threshold(1)
	space:idle_speed_threshold(10)
	
	local arbiter_pass={}  -- background tiles we can jump up through
		arbiter_pass.presolve=function(it)
			local points=it:points()
-- once we trigger headroom, we keep a table of headroom shapes and it is not reset until total separation
			if it.shape_b.in_body.headroom then
				local headroom=false
--					for n,v in pairs(it.shape_b.in_body.headroom) do headroom=true break end -- still touching an old headroom shape?
--					if ( (points.normal_y>0) or headroom) then -- can only headroom through non dense tiles
				if ( (points.normal_y>0) or it.shape_b.in_body.headroom[it.shape_a] ) then
					it.shape_b.in_body.headroom[it.shape_a]=true
					return it:ignore()
				end
			end
			
			return true
		end
		arbiter_pass.separate=function(it)
			if it.shape_a and it.shape_b and it.shape_b.in_body then
				if it.shape_b.in_body.headroom then it.shape_b.in_body.headroom[it.shape_a]=nil end
			end
		end
	space:add_handler(arbiter_pass,space:type("pass"))
	
	local arbiter_deadly={} -- deadly things
		arbiter_deadly.presolve=function(it)
			local callbacks=entities_manifest("callbacks")
			if it.shape_b.player then -- trigger die
				local pb=it.shape_b.player
				callbacks[#callbacks+1]=function() pb:die() end
			end
			return true
		end
	space:add_handler(arbiter_deadly,space:type("deadly"))

	local arbiter_crumbling={} -- crumbling tiles
		arbiter_crumbling.presolve=function(it)
			local points=it:points()
	-- once we trigger headroom, we keep a table of headroom shapes and it is not reset until total separation
			if it.shape_b.in_body.headroom then
				local headroom=false
	--				for n,v in pairs(it.shape_b.in_body.headroom) do headroom=true break end -- still touching an old headroom shape?
	--				if ( (points.normal_y>0) or headroom) then -- can only headroom through non dense tiles
				if ( (points.normal_y>0) or it.shape_b.in_body.headroom[it.shape_a] ) then
					it.shape_b.in_body.headroom[it.shape_a]=true
					return it:ignore()
				end
				local tile=it.shape_a.tile -- a humanoid is walking on this tile
				if tile then
					tile.level.updates[tile]=true -- start updates to animate this tile crumbling away
				end
			end
			
			return true
		end
		arbiter_crumbling.separate=function(it)
			if it.shape_a and it.shape_b and it.shape_b.in_body then
				if it.shape_b.in_body.headroom then -- only players types will have headroom
					it.shape_b.in_body.headroom[it.shape_a]=nil
				end
			end
		end
	space:add_handler(arbiter_crumbling,space:type("crumbling"))

	local arbiter_walking={} -- walking things (players)
		arbiter_walking.presolve=function(it)
			local callbacks=entities_manifest("callbacks")
			if it.shape_a.player and it.shape_b.monster then
				local pa=it.shape_a.player
				callbacks[#callbacks+1]=function() pa:die() end
			end
			if it.shape_a.monster and it.shape_b.player then
				local pb=it.shape_b.player
				callbacks[#callbacks+1]=function() pb:die() end
			end
			if it.shape_a.player and it.shape_b.player then -- two players touch
				local pa=it.shape_a.player
				local pb=it.shape_b.player
				if pa.active then
					if pb.bubble_active and pb.joined then -- burst
						callbacks[#callbacks+1]=function() pb:join() end
					end
				end				
				if pb.active then
					if pa.bubble_active and pa.joined then -- burst
						callbacks[#callbacks+1]=function() pa:join() end
					end
				end				
			end
			return true
		end
		arbiter_walking.postsolve=function(it)
			local points=it:points()
			if points.normal_y>0.25 then -- on floor
				local time=entities_get("time")
				it.shape_a.in_body.floor_time=time.game
				it.shape_a.in_body.floor=it.shape_b
			end
			return true
		end
	space:add_handler(arbiter_walking,space:type("walking")) -- walking things (players)

	local arbiter_loot={} -- loot things (pickups)
		arbiter_loot.presolve=function(it)
			if it.shape_a.loot and it.shape_b.player then -- trigger collect
				it.shape_a.loot.player=it.shape_b.player
			end
			return false
		end
	space:add_handler(arbiter_loot,space:type("loot")) 
	
	local arbiter_trigger={} -- trigger things
		arbiter_trigger.presolve=function(it)
			if it.shape_a.trigger and it.shape_b.triggered then -- trigger something
				it.shape_b.triggered.triggered = it.shape_a.trigger
			end
			return false
		end
	space:add_handler(arbiter_trigger,space:type("trigger"))

	local arbiter_menu={} -- menu things
		arbiter_menu.presolve=function(it)
			if it.shape_a.menu and it.shape_b.player then -- remember menu
				it.shape_b.player.near_menu=it.shape_a.menu
			end
			return false
		end
		arbiter_menu.separate=function(it)
			if it.shape_a and it.shape_a.menu and it.shape_b and it.shape_b.player then -- forget menu
				it.shape_b.player.near_menu=false
			end
			return true
		end
	space:add_handler(arbiter_menu,space:type("menu"))

	local arbiter_npc={} -- npc menu things
		arbiter_npc.presolve=function(it)
			if it.shape_a.npc and it.shape_b.player then -- remember npc menu
				it.shape_b.player.near_npc=it.shape_a.npc
			end
			return false
		end
		arbiter_npc.separate=function(it)
			if it.shape_a and it.shape_a.npc and it.shape_b and it.shape_b.player then -- forget npc menu
				it.shape_b.player.near_npc=false
			end
			return true
		end
	space:add_handler(arbiter_npc,space:type("npc"))

	return space
end


-- items, can be used for general things, EG physics shapes with no special actions
function add_item()
	local item=entities_add{caste="item"}
	item.draw=function()
		if item.active then
			local px,py,rz=item.px,item.py,item.rz
			if item.body then -- from fizix
				px,py=item.body:position()
				rz=item.body:angle()
			end
			rz=item.draw_rz or rz -- always face up?
			system.components.sprites.list_add({t=item.sprite,h=item.h,hx=item.hx,hy=item.hy,s=item.s,sx=item.sx,sy=item.sy,px=px,py=py,rz=180*rz/math.pi,color=item.color,pz=item.pz})
		end
	end
	return item
end


function setup_score()

	local score=entities_set("score",entities_add{})
	
	entities_set("time",{
		game=0,
	})
	
	score.update=function()
		local time=entities_get("time")
		time.game=time.game+(1/60)
	end

	score.draw=function()
	
		local time=entities_get("time")
	
		local remain=0
		for _,loot in ipairs( entities_items("loot") ) do
			if loot.active then remain=remain+1 end -- count remaining loots
		end
		if remain==0 and not time.finish then -- done
			time.finish=time.game
		end

		local t=time.start and ( (time.finish or time.game) - ( time.start ) ) or 0
		local ts=math.floor(t)
		local tp=math.floor((t%1)*100)

		local s=string.format("%d.%02d",ts,tp)
		system.components.text.text_print(s,math.floor((system.components.text.tilemap_hx-#s)/2),0)

		local s=""
		
		local level=entities_get("level")
		
		s=level.title or s

		for i,player in pairs(entities_items("player")) do
			if player.near_menu then
				s=player.near_menu.title
			end
		end

		system.components.text.text_print(s,math.floor((system.components.text.tilemap_hx-#s)/2),system.components.text.tilemap_hy-1)
		
	end
	
	return score
end

-- move it like a player or monster based on
-- it.move which is "left" or "right" to move 
-- it.jump which is true if we should jump
function char_controls(it,fast)
	fast=fast or 1

	local time=entities_get("time")

	local jump=fast*200 -- up velocity we want when jumping
	local speed=fast*60 -- required x velocity
	local airforce=speed*2 -- replaces surface velocity
	local groundforce=speed/2 -- helps surface velocity
	
	if ( time.game-it.body.floor_time < 0.125 ) or ( it.floor_time-time.game > 10 ) then -- floor available recently or not for a very long time (stuck)
	
		it.floor_time=time.game -- last time we had some floor

		it.shape:friction(1)

		if it.jump_clr and it.near_menu then
			local menu=entities_get("menu")
			local near_menu=it.near_menu
			local callbacks=entities_manifest("callbacks")
			callbacks[#callbacks+1]=function() menu.show(near_menu) end -- call later so we do not process menu input this frame
		end

		if it.jump_clr and it.near_npc then

			local callbacks=entities_manifest("callbacks")
			callbacks[#callbacks+1]=function()

				local chat=chats.get(it.near_npc)
				chat.set_response("welcome")
				menu.show( chat.get_menu_items() )

			end -- call later so we do not process menu input this frame

		end

		if it.jump then

			local vx,vy=it.body:velocity()

			if vy>-20 then -- only when pushing against the ground a little

				if it.near_menu or it.near_npc then -- no jump
				
				else
				
					vy=-jump
					it.body:velocity(vx,vy)
					
					it.body.floor_time=0
				
				end
				
			end

		end

		if it.move=="left" then
			
			local vx,vy=it.body:velocity()
			if vx>0 then it.body:velocity(0,vy) end
			
			it.shape:surface_velocity(speed,0)
			if vx>-speed then it.body:apply_force(-groundforce,0,0,0) end
			it.dir=-1
			it.frame=it.frame+1
			
		elseif it.move=="right" then

			local vx,vy=it.body:velocity()
			if vx<0 then it.body:velocity(0,vy) end

			it.shape:surface_velocity(-speed,0)
			if vx<speed then it.body:apply_force(groundforce,0,0,0) end
			it.dir= 1
			it.frame=it.frame+1

		else

			it.shape:surface_velocity(0,0)

		end
		
	else -- in air

		it.shape:friction(0)

		if it.move=="left" then
			
			local vx,vy=it.body:velocity()
			if vx>0 then it.body:velocity(0,vy) end

			if vx>-speed then it.body:apply_force(-airforce,0,0,0) end
			it.shape:surface_velocity(speed,0)
			it.dir=-1
			it.frame=it.frame+1
			
		elseif  it.move=="right" then

			local vx,vy=it.body:velocity()
			if vx<0 then it.body:velocity(0,vy) end

			if vx<speed then it.body:apply_force(airforce,0,0,0) end
			it.shape:surface_velocity(-speed,0)
			it.dir= 1
			it.frame=it.frame+1

		else

			it.shape:surface_velocity(0,0)

		end

	end
end


function add_player(i)
	local players_colors={30,14,18,7,3,22}

	local names=system.components.tiles.names
	local space=entities_get("space")

	local player=entities_add{caste="player"}

	player.idx=i
	player.score=0
	
	local t=bitdown.cmap[ players_colors[i] ]
	player.color={}
	player.color.r=t[1]/255
	player.color.g=t[2]/255
	player.color.b=t[3]/255
	player.color.a=t[4]/255
	player.color.idx=players_colors[i]
	
	player.up_text_x=math.ceil( (system.components.text.tilemap_hx/16)*( 1 + ((i>3 and i+2 or i)-1)*2 ) )

	player.frame=0
	player.frames={ names.player_f1.idx , names.player_f2.idx , names.player_f1.idx , names.player_f3.idx }
	
	player.join=function()
		local players_start=entities_get("players_start") or {64,64}
	
		local px,py=players_start[1]+i,players_start[2]
		local vx,vy=0,0

		player.bubble_active=false
		player.active=true
		player.body=space:body(1,math.huge)
		player.body:position(px,py)
		player.body:velocity(vx,vy)
		player.body.headroom={}
		
		player.body:velocity_func(function(body)
--				body.gravity_x=-body.gravity_x
--				body.gravity_y=-body.gravity_y
			return true
		end)
					
		player.floor_time=0 -- last time we had some floor

		player.shape=player.body:shape("segment",0,-4,0,4,4)
		player.shape:friction(1)
		player.shape:elasticity(0)
		player.shape:collision_type(space:type("walking")) -- walker
		player.shape.player=player
		
		player.body.floor_time=0
		local time=entities_get("time")
		if not time.start then
			time.start=time.game -- when the game started
		end
	end
	
	player.update=function()
		local up=ups(player.idx) -- the controls for this player
		
		player.move=false
		player.jump=up.button("fire")
		player.jump_clr=up.button("fire_clr")

		if use_only_two_keys then -- touch screen control test?

			if up.button("left") and up.button("right") then -- jump
				player.move=player.move_last
				player.jump=true
			elseif up.button("left") then -- left
				player.move_last="left"
				player.move="left"
			elseif up.button("right") then -- right
				player.move_last="right"
				player.move="right"
			end

		else

			if up.button("left") and up.button("right") then -- stop
				player.move=nil
			elseif up.button("left") then -- left
				player.move="left"
			elseif up.button("right") then -- right
				player.move="right"
			end

		end


		if not player.joined then
			player.joined=true
			player:join() -- join for real and remove bubble
		end

		if player.active then
		
			char_controls(player)
		
		end
	end
	

	player.draw=function()
		if player.bubble_active then

			local px,py=player.bubble_body:position()
			local rz=player.bubble_body:angle()
			player.frame=player.frame%16
			local t=player.frames[1+math.floor(player.frame/4)]
			
			system.components.sprites.list_add({t=t,h=24,px=px,py=py,sx=(player.dir or 1)*0.5,s=0.5,rz=180*rz/math.pi,color=player.color})
			
			system.components.sprites.list_add({t=names.bubble.idx,h=24,px=px,py=py,s=1})

		elseif player.active then
			local px,py=player.body:position()
			local rz=player.body:angle()
			player.frame=player.frame%16
			local t=player.frames[1+math.floor(player.frame/4)]
			
			system.components.sprites.list_add({t=t,h=24,px=px,py=py,sx=player.dir,sy=1,rz=180*rz/math.pi,color=player.color})			
		end

		if player.joined then
			local s=string.format("%d",player.score)
			system.components.text.text_print(s,math.floor(player.up_text_x-(#s/2)),0,player.color.idx)
		end

	end
	
	return player
end

function change_level(idx)

	setup_level(idx)
	
end

function setup_level(idx)

	local level=entities_set("level",entities_add{})

	local names=system.components.tiles.names

	level.updates={} -- tiles to update (animate)
	level.update=function()
		for v,b in pairs(level.updates) do -- update these things
			if v.update then v:update() end
		end
	end

-- init map and space

	local space=setup_space()

	local tilemap={}
	for n,v in pairs( levels[idx].legend ) do -- build tilemap from legend
		if v.name then -- convert name to tile
			tilemap[n]=names[v.name]
		end
	end

	local map=entities_set("map", bitdown.pix_tiles(  levels[idx].map,  levels[idx].legend ) )
	
	level.title=levels[idx].title
	
	bitdown.tile_grd( levels[idx].map, tilemap, system.components.map.tilemap_grd  ) -- draw into the screen (tiles)

	local unique=0
	bitdown.map_build_collision_strips(map,function(tile)
		unique=unique+1
		if tile.coll then -- can break the collision types up some more by appending a code to this setting
			if tile.collapse then -- make unique
				tile.coll=tile.coll..unique
			end
		end
	end)

	for y,line in pairs(map) do
		for x,tile in pairs(line) do
			local shape
			if tile.deadly then -- a deadly tile

				if tile.deadly==1 then
					shape=space.static:shape("poly",{x*8+4,y*8+8,(x+1)*8,(y+0)*8,(x+0)*8,(y+0)*8},0)
				else
					shape=space.static:shape("poly",{x*8+4,y*8,(x+1)*8,(y+1)*8,(x+0)*8,(y+1)*8},0)
				end
				shape:friction(1)
				shape:elasticity(1)
				shape.cx=x
				shape.cy=y
				shape:collision_type(space:type("deadly")) -- a tile that kills

			elseif tile.solid and (not tile.parent) then -- if we have no parent then we are the master tile
			
				local l=1
				local t=tile
				while t.child do t=t.child l=l+1 end -- count length of strip

				if     tile.link==1 then -- x strip
					shape=space.static:shape("box",x*8,y*8,(x+l)*8,(y+1)*8,0)
				elseif tile.link==-1 then  -- y strip
					shape=space.static:shape("box",x*8,y*8,(x+1)*8,(y+l)*8,0)
				else -- single box
					shape=space.static:shape("box",x*8,y*8,(x+1)*8,(y+1)*8,0)
				end

				shape:friction(tile.solid)
				shape:elasticity(tile.solid)
				shape.cx=x
				shape.cy=y
				shape.coll=tile.coll
				if tile.collapse then
					shape:collision_type(space:type("crumbling")) -- a tile that collapses when we walk on it
					tile.update=function(tile)
						tile.anim=(tile.anim or 0) + 1
						
						if tile.anim%4==0 then
							local dust=entities_get("dust")
							dust.add({
								vx=0,
								vy=0,
								px=(tile.x+math.random())*8,
								py=(tile.y+math.random())*8,
								life=60*2,
								friction=1,
								elasticity=0.75,
							})
						end

						if tile.anim > 60 then
							space:remove( tile.shape )
							tile.shape=nil
							system.components.map.tilemap_grd:pixels(tile.x,tile.y,1,1,{0,0,0,0})
							system.components.map.dirty(true)
							level.updates[tile]=nil
						else
							local name
							if     tile.anim < 20 then name="char_floor_collapse_1"
							elseif tile.anim < 40 then name="char_floor_collapse_2"
							else                       name="char_floor_collapse_3"
							end
							local idx=names[name].idx
							local v={}
							v[1]=(          (idx    )%256)
							v[2]=(math.floor(idx/256)%256)
							v[3]=31
							v[4]=0
							system.components.map.tilemap_grd:pixels(tile.x,tile.y,1,1,v)
							system.components.map.dirty(true)
						end
					end
				elseif not tile.dense then 
					shape:collision_type(space:type("pass")) -- a tile we can jump up through
				end
			end
			if tile.push then
				if shape then
					shape:surface_velocity(tile.push*12,0)
				end
				level.updates[tile]=true
				tile.update=function(tile)
					tile.anim=( (tile.anim or 0) + 1 )%20
					
					local name
					if     tile.anim <  5 then name="char_floor_move_1"
					elseif tile.anim < 10 then name="char_floor_move_2"
					elseif tile.anim < 15 then name="char_floor_move_3"
					else                       name="char_floor_move_4"
					end
					local idx=names[name].idx
					local v={}
					v[1]=(          (idx    )%256)
					v[2]=(math.floor(idx/256)%256)
					v[3]=31
					v[4]=0
					system.components.map.tilemap_grd:pixels(tile.x,tile.y,1,1,v)
					system.components.map.dirty(true)
				end
			end

			tile.map=map -- remember map
			tile.level=level -- remember level
			if shape then -- link shape and tile
				shape.tile=tile
				tile.shape=shape
			end
		end
	end


	for y,line in pairs(map) do
		for x,tile in pairs(line) do

			if tile.loot then
				local loot=add_loot()

				local shape=space.static:shape("box",x*8,y*8,(x+1)*8,(y+1)*8,0)
				shape:collision_type(space:type("loot"))
				shape.loot=loot
				loot.shape=shape
				loot.px=x*8+4
				loot.py=y*8+4
				loot.active=true
			end
			if tile.item then
				local item=add_item()
				
				item.sprite=names.cannon_ball.idx
				item.h=24

				item.active=true
				item.body=space:body(2,2)
				item.body:position(x*8+4,y*8+4)

				item.shape=item.body:shape("circle",8,0,0)
				item.shape:friction(0.5)
				item.shape:elasticity(0.5)

			end
			if tile.start then
				entities_set("players_start",{x*8+4,y*8+4}) --  remember start point
			end
			if tile.monster then
				local item=add_monster{
					px=x*8+4,py=y*8+4,
					vx=0,vy=0,
				}
			end
			if tile.trigger then
				local item=add_item()

				local shape=space.static:shape("box", x*8 - (tile.trigger*6) ,y*8, (x+1)*8 - (tile.trigger*6) ,(y+1)*8,0)
				item.shape=shape
				
				shape:collision_type(space:type("trigger"))
				shape.trigger=tile
			end
			if tile.menu then
				local item=add_item()

				item.shape=space.static:shape("box", (x-1)*8,(y-1)*8, (x+2)*8,(y+2)*8,0)
				
				item.shape:collision_type(space:type("menu"))
				item.shape.menu=tile.menu
			end
			if tile.sign then
				local items={}
				tile.items=items
				local px,py=x*8-(#tile.sign)*4 + (tile.sign_x or 0) ,y*8 + (tile.sign_y or 0)
				for i=1,#tile.sign do
					local item=add_item()
					items[i]=item

					item.sprite=tile.sign:byte(i)/2
					item.hx=4
					item.hy=8
					item.s=2

					item.active=true
					item.body=space:body(1,100)
					item.body:position(px+i*8-4 ,py+8 )

					item.shape=item.body:shape("box", -4 ,-8, 4 ,8,0)
					item.shape:friction(1)
					item.shape:elasticity(0.5)
					
					if tile.colors then item.color=tile.colors[ ((i-1)%#tile.colors)+1 ] end
										
					if items[i-1] then -- link
						item.constraint=space:constraint(item.body,items[i-1].body,"pin_joint", 0,-8 , 0,-8 )
						item.constraint:collide_bodies(false)
					end					
				end
				local item=items[1] -- first
				item.constraint_static=space:constraint(item.body,space.static,"pin_joint", 0,-8 , px-4,py )

				local item=items[#tile.sign] -- last
				item.constraint_static=space:constraint(item.body,space.static,"pin_joint", 0,-8 , px+#tile.sign*8+4,py )
			end
			if tile.spill then
				level.updates[tile]=true
				tile.update=function(tile)
					local dust=entities_get("dust")
					dust.add({
						vx=0,
						vy=0,
						px=(tile.x+math.random())*8,
						py=(tile.y+math.random())*8,
						life=60*2,
						friction=1,
						elasticity=0.75,
					})
				end
			end
			if tile.bubble then
				level.updates[tile]=true
				tile.update=function(tile)
					tile.count=((tile.count or tile.bubble.start )+ 1)%tile.bubble.rate
					if tile.count==0 then
						local dust=entities_get("dust")
						dust.add({
							vx=0,
							vy=0,
							px=(tile.x+math.random())*8,
							py=(tile.y+math.random())*8,
							sprite = names.bubble.idx,
							mass=1/64,inertia=1,
							h=24,
							s=1,
							shape_args={"circle",12,0,0},
							life=60*16,
							friction=0,
							elasticity=15/16,
							gravity={0,-64},
							draw_rz=0,
							die_speed=128,
							on_die=function(it) -- burst
								local px,py=it.body:position()
								for i=1,16 do
									local r=math.random(math.pi*2000)/1000
									local vx=math.sin(r)
									local vy=math.cos(r)
									dust.add({
										gravity={0,-64},
										mass=1/16384,
										vx=vx*100,
										vy=vy*100,
										px=px+vx*8,
										py=py+vy*8,
										friction=0,
										elasticity=0.75,
										sprite= names.char_dust_white.idx,
										life=15*(2+i),
									})
								end
							end
						})
					end
				end
			end
			if tile.sprite then
				local item=add_item()
				item.active=true
				item.px=tile.x*8+4
				item.py=tile.y*8+4
				item.sprite = names[tile.sprite].idx
				item.h=24
				item.s=1
				item.draw_rz=0
				item.pz=-1
			end
			if tile.npc then
				local item=add_item()

				item.shape=space.static:shape("box", (x-1)*8,(y-1)*8, (x+2)*8,(y+2)*8,0)

-- print("npc",x,y)

				item.shape:collision_type(space:type("npc"))
				item.shape.npc=tile.npc
			end
		end
	end
	
end

-----------------------------------------------------------------------------
--[[#setup_menu

	menu = setup_menu()

Create a displayable and controllable menu system that can be fed chat 
data for user display.

After setup, provide it with menu items to display using 
menu.show(items) then call update and draw each frame.


]]
-----------------------------------------------------------------------------
function setup_menu(items)

	local wstr=require("wetgenes.string")

	local menu=entities_set("menu",entities_add{})
--	local menu={}

	menu.stack={}

	menu.width=80-4
	menu.cursor=0
	menu.cx=math.floor((80-menu.width)/2)
	menu.cy=0
	
	function menu.show(items)
	
		if not items then
			menu.items=nil
			menu.lines=nil
			return
		end

		if items.call then items.call(items,menu) end -- refresh
		
		menu.items=items
		menu.cursor=items.cursor or 1
		
		menu.lines={}
		for idx=1,#items do
			local item=items[idx]
			local text=item.text
			if text then
				local ls=wstr.smart_wrap(text,menu.width-8)
				if #ls==0 then ls={""} end -- blank line
				for i=1,#ls do
					local prefix=""--(i>1 and " " or "")
					if item.cursor then prefix=" " end -- indent decisions
					menu.lines[#menu.lines+1]={s=prefix..ls[i],idx=idx,item=item,cursor=item.cursor,color=item.color}
				end
			end
		end

	end


	
	menu.update=function()
	
		if not menu.items then return end

		local bfire,bup,bdown,bleft,bright
		
		for i=0,5 do -- any player, press a button, to control menu
			local up=ups(i)
			if up then
				bfire =bfire  or up.button("fire_clr")
				bup   =bup    or up.button("up_set")
				bdown =bdown  or up.button("down_set")
				bleft =bleft  or up.button("left_set")
				bright=bright or up.button("right_set")
			end
		end
		

		if bfire then

			for i,item in ipairs(menu.items) do
			
				if item.cursor==menu.cursor then
			
					if item.call then -- do this
					
						if item and item.decision and item.decision.name=="exit" then --exit menu
							menu.show()	-- hide
						else
							item.call( item , menu )
						end
					end
					
					break
				end
			end
		end
		
		if bleft or bup then
		
			menu.cursor=menu.cursor-1
			if menu.cursor<1 then menu.cursor=menu.items.cursor_max end

		end
		
		if bright or bdown then
			
			menu.cursor=menu.cursor+1
			if menu.cursor>menu.items.cursor_max then menu.cursor=1 end
		
		end
	
	end
	
	menu.draw=function()

		local tprint=system.components.text.text_print
		local tgrd=system.components.text.tilemap_grd

		if not menu.lines then return end
		
		menu.cy=math.floor((30-(#menu.lines+4))/2)
		
		tgrd:clip(menu.cx,menu.cy,0,menu.width,#menu.lines+4,1):clear(0x02000000)
		tgrd:clip(menu.cx+2,menu.cy+1,0,menu.width-4,#menu.lines+4-2,1):clear(0x01000000)
		
		if menu.items.title then
			local title=" "..(menu.items.title).." "
			local wo2=math.floor(#title/2)
			tprint(title,menu.cx+(menu.width/2)-wo2,menu.cy+0,31,2)
		end
		
		for i,v in ipairs(menu.lines) do
			tprint(v.s,menu.cx+4,menu.cy+i+1,v.color or 31,1)
		end
		
		local it=nil
		for i=1,#menu.lines do
			if it~=menu.lines[i].item then -- first line only
				it=menu.lines[i].item
				if it.cursor == menu.cursor then
					tprint(">",menu.cx+4,menu.cy+i+1,31,1)
				end
			end
		end

		system.components.text.dirty(true)

	end
	

	if items then menu.show(items) end
	
	return menu
end


-----------------------------------------------------------------------------
--[[#update

	update()

Update and draw loop, called every frame.

]]
-----------------------------------------------------------------------------
update=function()

	if not setup_done then

		local it=system.components.copper
		it.shader_name="fun_copper_back_y5"
		it.shader_uniforms.cy0={ 0.55 , 0.00 , 0.00 , 1   }
		it.shader_uniforms.cy1={ 0.00 , 0.00 , 0.40 , 1   }
		it.shader_uniforms.cy2={ 0.05 , 0.15 , 0.40 , 1   }
		it.shader_uniforms.cy3={ 0.00 , 0.00 , 0.40 , 1   }
		it.shader_uniforms.cy4={ 0.05 , 0.05 , 0.05 , 1   }

		entities_reset()

		chats=chatdown.setup(chat_text)
		menu=setup_menu() -- chats.get_menu_items("example") )

		setup_score()
		
		setup_level(1) -- load map
		
		add_player(1) -- add a player

		setup_done=true
	end
	
	if menu.lines then -- menu only, pause the entities
		menu.update()
		menu.draw()
	else
		entities_call("update")
		local space=entities_get("space")
		space:step(1/(60*2)) -- double step for increased stability, allows faster velocities.
		space:step(1/(60*2))
	end

	-- run all the callbacks created by collisions 
	for _,f in pairs(entities_manifest("callbacks")) do f() end
	entities_set("callbacks",{}) -- and reset the list

	entities_call("draw") -- because we are going to add them all in again here
	
end
