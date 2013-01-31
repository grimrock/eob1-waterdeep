local WentlysNote = {}

WentlysNote[1] = { text = [[
My name is Wently Kelso, a famous archeologist. 
During this expedition to the deepest depths of
the sewers of Waterdeep, I'll write notes for my
latest book entitled "The World Beneath Waterdeep".

Our guide on expedition is a mangy humanoid of
indeterminate species. I can't pronounce his real
name, so I call him Bennet, in honor of my mangy
half-brother on my mothers side of the family. As
we followed Bennet into the tunnels and catacombs
of the sewer system, we can hear the soft foot
steps of large dog-like creatures known as Kobolds.
]], l = 1, x = 11, y = 15, f = 0 }

WentlysNote[2] = { text = [[
This area was used to control the water flow
through the first level of the sewer system.
If the water flowed from the north, certain
passageways would close to prevent the water
from flooding the level. The same would happen
if the water flowed from the east.
]], l = 1, x = 15, y = 12, f = 1 }

WentlysNote[3] = { text = [[
According to the city sewer layout, some of the
doors require a constant flow of water over their
pressure plate to remain open. Once the water
stopped flowing over the pressure plate, the door
would close, to prevent backwash.
]], l = 1, x = 21, y = 18, f = 0 }

WentlysNote[4] = { text = [[
Our guide, Bennet, pointed out a secret door here.
He tried (with our help) to bash the door in with
his head but was unsuccessful. There must be a 
secret button or lever around here somewhere.
]], l = 1, x = 25, y = 22, f = 1 }

WentlysNote[5] = { text = [[
There is a depression in the north wall with rolled
up papers inside. I am surprised that the papers
survived. I would have thought that unprotected
paper would rot in the sewer.
]], l = 1, x = 12, y = 25, f = 1 }

WentlysNote[6] = { text = [[
Here we found an emergency flood control door.
It is designed so that if the area flooded any
trapped workers could open the door by pushing
the button. The water would rush down into the
second level saving the workers.
]], l = 1, x = 16, y = 24, f = 2 }

WentlysNote[7] = { text = [[
We looked down the long dark hole that led to the
second level of the sewer system. The smell of
rotting flesh filled our nostrils and we decided
that the Bennet, our guide, should go down first.
Looking down into the dark, he became frightened
and stopped about five feet down. We encouraged him
to continue on by dropping rocks down the hole.
]], l = 2, x = 19, y = 23, f = 1 }

WentlysNote[8] = { text = [[
This door was stuck partially open. Bennet gripped
the bottom of the door and pulled up as hard as he
could. By his whining I assume that he has somehow
hurt himself.
]], l = 2, x = 19, y = 18, f = 0 }

WentlysNote[9] = { text = [[
Our guide was overcome by sewer gas around here
somewhere. He spun around a couple of times and
ended up facing the wrong direction.
]], l = 2, x = 19, y = 26, f = 1 }

WentlysNote[10] = { text = [[
This area is an emergency exit. If the water level
became too high for the workers to get out, they
would step into this area and it would teleport
them to the surface. Unfortunately, the teleporter
has broken down and it will only teleport you to
another area within the sewer system. I don't know
how we will we ever find our passage out of here.
]], l = 2, x = 24, y = 28, f = 3 }

WentlysNote[11] = { text = [[
When our guide read "R.A.T.S." he ran in terror.
We had to track him down and drag him back.
The city sewer map claims that R.A.T.S. stands for
Rapid Access Teleport System. 
I wonder where it will teleport you to.
]], l = 2, x = 9, y = 25, f = 1 }

WentlysNote[12] = { text = [[
This area appears to be a shuttle of some kind.
We pushed the button and the door closed. Then,
we pushed the button again and there was a strange
sound. 
What does the inscription on the side wall mean?
]], l = 2, x = 10, y = 21, f = 2 }

WentlysNote[13] = { text = [[
We were warned by our guide not to push the button
on the wall in the cell of north-west room.
What does our guide know? I pushed it anyway.
I wonder what will happen.
]], l = 2, x = 13, y = 12, f = 3 }

WentlysNote[14] = { text = [[
This keyhole in north-west corridor is different
than the others we have run into thus far.
Does it require a special key?
]], l = 2, x = 22, y = 8, f = 1 }

WentlysNote[15] = { text = [[
The stench of sewer gas makes our heads spin.
Our guide, Bennet, has informed us that this is
the perfect environment for the kuo-toa.
We will have to keep our guard up.
]], l = 3, x = 26, y = 5, f = 1 }

cloneObject{
	name = "wentlys_note",
	baseObject = "note",
	uiName = "Wently's note",
}

cloneObject{
	name = "WentlysNoteSpawner",
	baseObject = "dungeon_door_metal",
	onOpen = function()
		for id,wnote in pairs(WentlysNote) do
			spawn("wentlys_note", wnote.l, wnote.x, wnote.y, wnote.f ):setScrollText("Note #"..id.."\n--------------\n"..wnote.text.."\n~Wently Kelso")
		end
		fw.debugPrint("Wentlys Notes spawned ("..#WentlysNote..")")
		spawn("counter", 1, 1, 2, 0, "wentlys_note_total"):setValue(#WentlysNote)
	end
}