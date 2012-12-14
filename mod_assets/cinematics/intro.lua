-- Cinematic with a title and story text
enableUserInput()
startMusic("mod_assets/samples/music/title-music-amiga.ogg")

showImage("mod_assets/textures/cinematic/intro/slide001_waterdeep.tga")
fadeIn(1)

-- show the title text
setFont("IntroTitle")
showText("Waterdeep Sewers", 3)
sleep(2)
fadeOutText(1)

-- show the story text
sleep(1)
setFont("Intro")
textWriter([[
Waterdeep is a port city that is located along the western coast of the Faerun sub-continent.
Known as the City of Splendors, Waterdeep is one of the largest and busiest cities and one
of the most important political powers—on the continent.
The population is primarily human, although other races dwell therein.
]])
click()
fadeOutText(0.5)
textWriter([[
The city government consists of a cryptocracy of (mostly) anonymous individuals known as
the Masked Lords of Waterdeep. Piergeiron the Paladinson, Warden of Waterdeep and Commander
of the Watch, whose golden-spired palace dominates the center of the city,
is a member of the Lords.
He is the Unmasked Lord and wears no mask over either his face or his heart. The archmage
Khelben "Blackstaff" Arunsun was also of the Lords, and perhaps chief among them,
exceeding even Piergeiron.
Underneath a rise in the western part of the city is an extensive
complex of tunnels and chambers known as the Undermountain.
]])
click()
fadeOutText(0.5)
fadeOut(0.5)

showImage("mod_assets/textures/cinematic/intro/slide_black.tga")
fadeIn(0.1)

-- The Meeting TITLE
setFont("IntroTitle")
showText("The Meeting", 3)
sleep(2)
fadeOutText(0.5)

setFont("Intro")
textWriter([[
Piergeiron, the chief Lord of Waterdeep, has called the party to a meeting
and gives you the following letter:
]])
sleep(3)
fadeOutText(0.5)
fadeOut(0.5)
showImage("mod_assets/textures/cinematic/intro/slide002_letter.tga")
fadeIn(1)
click()
fadeOut(0.5)
showImage("mod_assets/textures/cinematic/intro/slide003.tga")
fadeIn(1)
click()
fadeOut(0.5)
showImage("mod_assets/textures/cinematic/intro/slide004.tga")
fadeIn(1)
click()
fadeOut(0.5)
showImage("mod_assets/textures/cinematic/intro/slide005.tga")
fadeIn(1)
click()
fadeOut(0.5)

showImage("mod_assets/textures/cinematic/intro/slide_black.tga")
fadeIn(0.1)

-- The Commission TITLE
setFont("IntroTitle")
showText("The Commission", 3)
sleep(2)
fadeOutText(0.5)

setFont("Intro")
textWriter([[
"The sewers" Piergeiron says.
"I would hide in the sewers. And that is where I think you should start."
He hands you an official document with the seal of Waterdeep prominently displayed.
]])
click()
fadeOutText(1)
showImage("mod_assets/textures/cinematic/intro/slide006.tga")
fadeIn(1)
click()
fadeOut(1)
showImage("mod_assets/textures/cinematic/intro/slide007.tga")
fadeIn(1)
click()
fadeOut(1)

showImage("mod_assets/textures/cinematic/intro/slide_black.tga")
fadeIn(0.1)

-- The Sewers TITLE
setFont("IntroTitle")
showText("The Sewers", 3)
sleep(2)
fadeOutText(0.5)
fadeOut(0.1)

fadeOutMusic(2)