	rem ==========================================================
	rem Papilio Retrocade - Atari 2600 default splash cartridge
	rem Uses only documented batari Basic (bB) commands - see:
	rem https://alienbill.com/2600/basic/downloads/0.35/help.html
	rem ==========================================================

	set romsize 2k

	dim huecolor = a

	player0x = 76 : player0y = 80
	COLUP0 = $1c

	rem "P" logo mark, 8 wide. Rows are bottom-to-top in bB.
	player0:
	%11000000
	%11000000
	%11000000
	%11000000
	%11111100
	%11000110
	%11000110
	%11000110
	%11111100
	end

main
	huecolor = huecolor + 1
	COLUBK = huecolor & $0e
	COLUPF = $1c

	rem border frame on the 32x11 playfield grid
	pfhline 0 0 31 on
	pfhline 0 10 31 on
	pfvline 0 0 10 on
	pfvline 31 0 10 on

	if joy0fire then huecolor = 0

	drawscreen
	goto main
