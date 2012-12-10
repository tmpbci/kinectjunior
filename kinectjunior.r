
    REBOL [ Title: "Junior Kinect" 
    
    author: Sam Neurohack
	note: "Control a bioloid robot with a kinect"
	Version: 0.1]

;;
;; 1. Needs the MAX/MSP udp/OSC port translater 12347 to 12348 otherwise Synapse crash on startup
;; 2. Needs the robnet.rb in ruby to talk to Junior serial port
;;
;; Bioloid beginner robot in penguin mode
;;
;; INIT sequence : motornumber position : 1 500 / 2 500 / 3 500 / 4 500
;;
;; left arm    2 : back  250 / 500 / 825
;; right arm   1 :  back 750 / 500 / 200
;; right leg   3 : stand / 500 /
;; left leg    4 : stand
;;
;; 
;; Quick and dirty Osc server in Rebol support only data with float type (no test)
;; 
;; oscport =  12348
;; oscaddress = received osc command.
;; oscvalue =  received [value1 value2 ...]
;; nbargs = number of received OSC arguments
;;
;; float function : See end of code for License information
;;

motorleft: "2"
motoright: "1"
leftmini: 500
leftstart: 650
leftend: 825
leftstep: 57.5		; (leftend - leftstart) / 10
rightmini: 500
rightstart: 350
rightend: 200
rightstep: -55		; (rightend - rightstart) / 4
motorstart: rightstart
motorend: rightend
motorstep: rightstep
rightcurrentpos: rightstart - 100
oldrightcurrentpos: rightstart
leftcurrentpos: leftstart - 100
oldleftcurrentpos: leftstart
oldleftosc: 0
oldrightosc: 0
motor: motoright

leftcommand: "/lefthand_pos_screen"
rightcommand: "/righthand_pos_screen"

debug: 0
osc: 0
oscport: 12348

from-ieee: func [
 "Zamienia binarna liczbe float ieee-32 na number!"
 [catch]
  dat [binary!] "liczba w formacie ieee-32"
 /local ieee-sign ieee-exponent ieee-mantissa] [

  ieee-sign: func [dat] [either zero? ((to-integer dat) and (to-integer 2#{10000000000000000000000000000000})) [1][-1]] ;; 1 bit
  ieee-exponent: func [dat] [
    exp: (to-integer dat) and (to-integer 2#{01111111100000000000000000000000}) ;; 8 bitow
    exp: (exp / power 2 23) - 127 ;; 127=[2^(k-1) - 1] (k=8 dla IEEE-32bit)
  ]
  ieee-mantissa: func [dat] [
    ((to-integer dat) and 
     (to-integer 2#{00000000011111111111111111111111})) + (to-integer (1 * power 2 23)) ;; 23 bity
  ]

  s: ieee-sign dat
  e: ieee-exponent dat
  m: ieee-mantissa dat
  d: s * (to-integer m) / power 2 (23 - e)
]

;;
;; Init OSC connection
;;

initosc: does 	[osc: 1
				newmsg: make binary! 5000
				my-address: read make url! join "dns://" (read dns://)
				print my-address
				oscserver: do reduce ajoin ["open/binary udp://:" oscport]
				oscaddress: []
				oscvalue: array [100]
				]
  
;;
;; End OSC connection
;;

endosc: does [
			either osc = 0 [print "OSC wasn't started"]
							[close oscserver]
    		]


;;
;; Junior commands translater and serial insert 
;;

dojunior: does [

			if oscommand = "/lefthand_pos_screen" [
										;print oscommand
										;print oscvalue/1
										lefthandtext/text: to-string oscvalue/1
										show lefthandtext
										if oscvalue/1 < 100 [leftcurrentpos: leftmini]
										if all [oscvalue/1 > 99 oscvalue/1 < 301] [leftcurrentpos: leftstart]
										if oscvalue/1 > 300 [leftcurrentpos: leftend]
										
										if leftcurrentpos <> oldleftcurrentpos [
															print oscommand
															print oscvalue/1
															juncommand: ajoin ["go " leftcurrentpos " 100"]
															print juncommand
															insert Junior "cid 2"
															wait 0.1
															insert Junior juncommand
															wait 0.5
															oldleftcurrentpos: leftcurrentpos
															leftcurrentpostext/text: to-string leftcurrentpos
															show leftcurrentpostext
															]

										]
			if oscommand = "/righthand_pos_screen" [
										;print oscommand
										;print oscvalue/1
										righthandtext/text: to-string oscvalue/1
										show righthandtext
										if oscvalue/1 < 400 [rightcurrentpos: rightend]
										if all [oscvalue/1 > 399 oscvalue/1 < 501] [rightcurrentpos: rightstart]
										if oscvalue/1 > 500 [rightcurrentpos: rightmini]
										if rightcurrentpos <> oldrightcurrentpos [
																print oscommand
																print oscvalue/1
																juncommand: ajoin ["go " rightcurrentpos " 100"]
																print juncommand
																insert Junior "cid 1"
																wait 0.1
																insert Junior juncommand
																wait 0.5
																oldrightcurrentpos: rightcurrentpos
																rightcurrentpostext/text: to-string rightcurrentpos
																show rightcurrentpostext
																]
											]
				]
;;
;; split newmsg
;;

splitosc: does [
			msglength: length? newmsg
			searchcoma: 0											; search end of osc command (ascii letters)
			while [(copy/part skip newmsg searchcoma 1) <> #{2C}] [searchcoma: searchcoma + 4
																	;print copy/part skip newmsg searchcoma 1
																	]
			;print searchcoma
			oscommand: trim/tail to-string copy/part skip newmsg 0 (searchcoma - 1)
			
			
			msgblocks: msglength / 4										; total of packets blocks
			argsblocks: msgblocks - to-integer (searchcoma / 4)				; nb of blocks from "," to end
			nbargs: argsblocks - 1 - to-integer (argsblocks / 5)			; nbargs 
			;print ajoin ["msgblocks : " msgblocks " argblocks : " argsblocks " nbargs : " nbargs]
			for values 1 nbargs 1											; read args -> oscvalue array
						[
						value: copy/part skip newmsg (((msgblocks - nbargs - 1) + values) * 4) 4
						;print value
						oscvalue/(values): from-ieee value
						]
			;print oscommand
			;print oscvalue
			dojunior
			]
			
			
;;
;; readosc 
;; 


readosc: does [
			print "readosc"
			forever [
					until [  error? try [
								receive: wait oscserver
								newmsg: copy oscserver
								newmsg: to-binary newmsg
								;print newmsg
								splitosc
								]
							]
					]
			]

;;
;; Controllers UI
;;

controllers: layout [
	anti-alias on
	backdrop effect [gradient 1x1 0.0.0 50.50.50] 
	at 20x10 text "Junior" white
	at 20x35 status: info bold "Junior v0.3. Start to connect" 220x25 font-color white 
	at 20x70 text "Live Play" snow  
	
	at 130x10 lefthandtext: text "00000" gray  
	at 180x10 righthandtext: text "00000" gray
	at 130x70 leftcurrentpostext: text "00000" gray 
	at 197x70 rightcurrentpostext: text "00000" snow
	
	at 20x95 button 70 50.50.50 edge [size: 1x1] "Start" [either osc = 0
    															[
    															status/text: "Error: OSCon first"
    															show status]
    															[readosc]
															]
	at 100x95 button 70 50.50.50 edge [size: 1x1] "Stop" [
														either error? try [testnet: open/binary/no-wait tcp://localhost:13859
																				]
    																[status/text: "Error: No Robnet server"
    																show status]
    																[status/font/color: snow
																	status/text: "Ready"
																	show status
																	close tp
																	]		
															]


	at 20x127 button 70 50.50.50 edge [size: 1x1] "RobON" 	[robot: 1						
															Junior: open/lines/no-wait tcp://127.0.0.1:13859
															status/text: "Link OK"
															show status
															]														
	at 100x127 button 70 50.50.50 edge [size: 1x1] "RobOFF" [robot: 0							
															close Junior
															]
	at 185x127 button 70 50.50.50 edge [size: 1x1] "Robinit" [status/text: "Initialisation"
															show status
															insert Junior "cid 2"
															wait 0.5
															insert Junior "go 500 100"
															wait 0.5
															insert Junior "cid 3"
															wait 0.5
															insert Junior "go 500 100"
															wait 0.5
															insert Junior "cid 4"
															wait 0.5
															insert Junior "go 500 100"
															wait 0.5
															insert Junior "cid 1"
															wait 0.5
															insert Junior "go 500 100"
															wait 0.5
															status/text: "End init"
															show status]
	at 20x159 button 70 50.50.50 edge [size: 1x1] "OSCon" [either osc = 1 [ 
    																	status/text: "Osc already open"
    																	show status]
    																	[initosc]
															]
	at 100x159 button 70 50.50.50 edge [size: 1x1] "OSCoff" [
															either osc = 0 
    																[status/text: "Error: OSC not open"
    																show status]
    																[status/font/color: snow
    																endosc
																	status/text: "Ready"
																	show status
																	]		
															]
	at 185x95 button 70 50.50.50 edge [size: 1x1] "Quit" [quit]	
]

;;
;; Main Program
;;

view/new controllers

lefthandtext/text: to-string leftstart
show lefthandtext
righthandtext/text: to-string rightstart
show righthandtext
leftcurrentpostext/text: to-string leftstart
show leftcurrentpostext
rightcurrentpostext/text: to-string rightstart
show rightcurrentpostext

do-events


;;
;; rebOSClient.r use ieee.r by Piotr Gapinski 2004-01-28 with "GNU Lesser General Public License (Version 2.1)"
;; 									  		  Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl"