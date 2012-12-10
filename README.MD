Kinect Junior v0.1
by Sam Neurohack
samneurohack at gmail dot com


Basic control of bioloid beginner with a kinect in rebol.
kinectjunior connects to Synapse OSC server, study left and right hands positions and drive the bioloid arms through serial port.
As the serial link in rebol is buggy on OS X, a crappy tcp to serial server in ruby is used, remember to modify the serial port name in robnet.rb (i.e change /dev/cu.PL2303-003012FD to COM4). You can use any other tcp -> serial program.

Build the pinguin model.
Launch Synapse Pasthrough in Pure Data or Max/MSP.
Launch Synapse to get OSC Datas. Synapse crash at startup if some OSC data doesn't come to 12346 port, so it needs the Passthrough launched first.
Launch tcp -> serial server : ruby robnet.rb
Launch rebol kinectjunior.r

Init sequence : RobON, Robinit and OSCon.
Start

As is the robot has 3 arms positions only. Feel free to mail if you get any trouble with kinectjunior.
kinectjunior has been successfully tested on OS X. If you can get Synapse working for windows it should work too.

Todo : Easier to launch process. Support other Kinect OSC bridge like OSCeleton. Better TCP -> Serial server

-----------------------------------------------------------------------------------------

Contrôle basique d'un robot bioloid beginner avec une kinect en rebol.
Kinectjunior se connecte au serveur OSC de Synapse, analyse les coordonnées des mains droites et gauches et commande les positions des bras via le port série du robot. Le lien série en rebol sous OS X est buggy donc un serveur tcp -> serie en ruby est utilisé. La prochaine version sera plus simple d'utilisation.


Construire le modèle pinguoin qui applaudit des 2 mains.
Lancer le Passthrough en Pure Data ou celui en Max/MSP qui vient avec Synapse sinon Synapse plante au demarrage.
Lancer Synapse pour avoir les données OSC. 
taper ruby robnet.rb (voir le source pour installer les dépendances).
taper rebol kinectjunior.r

Initialisation : RobON, Robinit et OSCon.
Start

En l'etat actuel, le robot a 3 positions d'ouverture de bras. Ne pas hésiter a m'envoyer un mail concernant tout problème rencontré avec kinectjunior. Kinectjunior a ete testé sur OS X. Il devrait fonctionner sur Windows si vous arrivez a installer Synapse.

A faire : Démarrage moins complexe et supporter d'autres ponts Kinect -> OSC comme OSCeleton.
