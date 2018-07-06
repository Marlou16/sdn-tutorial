# sdn-tutorial

Welkom bij deze tutorial waar je kennis zult maken met Software Defined Networking. Na het volgend van deze tutorial heb je je eigen virtuele omgeving opgezet en zou je in staat moten zijn om met `Mininet` een gevirtualiseerd netwerk op te zetten dat aangestuurd gaat worden met de `ONOS` (SDN) controller. op deze controller kan je een specifieke applicatie installeren die door middel van `Intents` het verkeer door het netwerk stuurt. Ook zal deze tutorial alles in de juiste context te plaatsen.

_Deze tutorial volgt de eerste versie van de SDN tutorial die ge, welke hier in PDF vorm te downloaden is._
_Daarnaast is er een kleine powerpoint waarin je kunt zien hoe communicatie verloopt in een traditioneel netwerk en in een SDN netwerk._

##### Benodigde kennis #####
Je hoeft geen netwerk expert te zijn om dit te kunnen volgen, maar het is de bedoeling dat je je juist een beetje netwerk expert gáát voelen. Daarnaast gaan we onze eigen virtuele omgeving opzetten en werken we veelal met de command line. Wees gedurende de tutorial vooral niet bang om random dingen te proberen en op te zoeken - het Internet is je vriend!

![banner image](/images/tutorial-banner.png)

&nbsp;
### Voorbereiding ###
Voordat we kunnen beginnen moeten we de virtuele omgeving opzetten. We gaan onze eigen Virtuele Machine inrichting die draait in VirtualBox.
VirtualBox kun je [hier](https://www.virtualbox.org/wiki/Downloads) downloaden, de VM die we gaan uitbreiden kan je [hier]((https://github.com/mininet/mininet/wiki/Mininet-VM-Images)) downloaden.
Op deze VM staat al `Mininet` geïnstalleerd, maar we gaan deze uitbreiden met een GUI, web browser en intallatie van de `ONOS` controller.

Wanneer je de VM hebt geïmporteerd in VirtualBox, start deze dan nog niet op, maar ga naar de instellingen van de VM.
In het sub-menu voor 'Systeem', zet het geheugen op 2048MB.
Controleer in het sub-menu 'Netwerk' of Adapter 1 op NAT ingesteld staat.
Wanneer je de VM opstart, kom je in een terminal terecht. De VM heeft nog niets anders. Allereerst de inloggegevens, deze zijn `mininet/mininet`.
Vervolgens, in de terminal, voer je de volgende commando's uit:

__let op: zorg dat je NIET op een/het bedrijfsnetwerk zit__

installeer de GUI en VM Guest Additions (voor een betere resolutie):
```
sudp apt-get update
sudo apt-get install xinit lxterminal lxde-common lxsession openbox
sudo apt-get install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
```

We hebben `java(8)` nodig:
```
sudo apt-get install python-software-properties software-properties-common
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracel-java8-installer oracle-java8-set-default
```

installeer `Wireshark`, een browser en text-editor:
```
sudo apt-get install chromium-browser
sudo apt-get install gedit
sudo apt-get install Wireshark
```

Voor __ONOS__, download eerst 1.10.4 versie in `tar.gz` formaat op [deze site](https://wiki.onosproject.org/display/ONOS/Downloads) (op de VM!) en doe dan:
```
cd Downloads
tar -zxvf onos-1.10.4-tar.gz
mv onos-1.10.4 ~/
cd ..
```

Als het goed is ben je op dit moment in de zogenaamde 'home-folder' `/home/mininet/`.
Dit kan je controleren met het commando `pwd`.

Als alles goed is gegaan dan ben je er klaar voor.
Daarnaast is deze VM ook nog uitermate geschikt om ná deze tutorial nog verder mee te spelen.

__Op de VM open je de GUI met het commando `startx`.
Vervolgens kan je een terminal openen met de sneltoets `Ctrl+Alt+T`__

Voor de tutorial heb je ook nog de bestanden _triangle.py_ en _onos-app-ifwd-1.9.0-SNAPSHOT.oar_ nodig, welke op deze pagina te downloaden zijn.
Je kan deze bestanden in een `.zip` map downloaden (op de VM zelf).
Uiteindelijk moeten deze bestanden in je home-folder terecht komen (`/home/mininet`).

&nbsp;
### Ontdek ONOS (Open Network Operating System) ###
ONOS is een _open source_ controller, geschreven in Java.
Je mag de code gratis gebruiken, inzien en naar eigen believen aanpassen (op je eigen systeem).
Programmeurs over heel de wereld hebben hieraan meegewerkt.
Alle documentatie (en nog meer tutorials/tips) is te vinden op hun [wiki](https://wiki.onosproject.org/display/ONOS/Wiki+Home).

Laten we beginnen met het opstarten van de SDN-controller.
Dit kan door het volgende commando vanuit de home-folder uit te voeren:
```
sudo ./onos-1.10.4/apache-karaf-3.0.8/bin/karaf clean
```
__tip__: Je kan een folder-naam laten 'auto-completen' met de TAB toets.

Als het goed is, start nu de Command Line Interface (CLI) van de controller op (_heb geduld!_).
ONOS gebruikt hiervoor de tool `KARAF` - maar daar gaan we in deze tutorial niet verder op in.

![onos cli](/images/onos-apps.png)

Vanaf de CLI kan je de controller besturen door verschillende commando's uit te voeren.
Hierdoor kan je verschillende applicaties activeren.
Om de controller ook daadwerkelijk nuttige dingen te laten doen, is dit nodig - ONOS heeft een collectie aan functionaliteiten in apps gegoten die je aan/uit kunt zetten.
Voor de basis-applicaties, voer de volgende commando's uit:
```
app activate org.onosproject.openflow
app activate org.onosproject.drivers
apps -s -a
```
Als het goed is, wanneer je het laatste commando uitvoert, krijg je dezelfde lijst met geactiveerde applicaties te zien als op de afbeelding hierboven.
Zo niet, dan kan/moet je ze even los activeren.

__Extra__: _in het commando `apps -s -a` betekent de optie `-s` dat je een samenvattend resultaat wil zien en `-a` dat je alleen de geactiveerde applicaties wil zien. Wanneer je `apps --help` doet, krijg je een lijst van alle opties voor het commando `apps` te zien. In de ONOS CLI kan je `--help` gebruiken achter elk commando als je er meer over wilt weten._

ONOS sluit je af met het commando `logout`.

&nbsp;
### Je eigen netwerk met Mininet ###
Leuk, zo'n controller, maar we kunnen nog niets omdat we nog geen netwerk hebben!
`Mininet` is een tool waarmee je gemakkelijk een virtueel netwerk op kan zetten.
Dez tool wordt voornamelijk gebruikt om netwerkjes te creëren dat `Open vSwitches` bevat.
Een `Open vSwitch` is een typische SDN-switch: een 'domme' switch die een controller nodig heeft om te functioneren.
Om `Mininet` helemaal te ontdekken raad ik je aan een van de beschikbare tutorials te volgend die je online kan vinden.

*Open een nieuwe terminal (of tabblad)*. Mininet kan je opstarten met het volgende commando:
```
sudo mn --topo tree,2,3 --controller remote,ip=127.0.0.1,port=6633 --switch ovsk,protocols=OpenFlow13
```

Kortweg doe je de volgende dingen met dit commando:
- Je kiest de topologie van het netwerk mt `--topo`. In dit geval bouwen we een 'boom' structuur met diepte 2 en 3 devices/hosts per laag.
- We verbinden ons netwerk aan een controller de 'remote' (op een andere locatie) is, en geven daarbij een IP-adres en port mee waarop we de controller denken te kunnen bereiken.
Het `OpenFlow` protocol gebruikt standaard port 6633 of 6653, en in dit geval draait de controller op dezelfde computer dus kunnen we het *localhost* IP-adres gebruiken.
- We definiëren de switches als `Open vSwitch` met `OpenFlow 1.3`.
- We zetten met `--mac` het gebruik van simpele MAC addressen aan.
Zo krijgt het IP-adres 10.0.0.1 een MAC 00:00:00:00:00:01).

![tree mininet](/images/mininet-start.png)

Via Mininet heb je toegang tot een apart CLI waar je verschillende commando's kan voeren die dingen op het netwerk uitvoeren, zoals `h1 ping h2` of `xterm h1` (opent een aparte terminal voor host 1) of `exit`.
Wanneer je alle informatie van het netwerk wil hebben, is het commando `dump` interessant:

![dump mininet](/images/dump.png)

&nbsp;
### Verkeer over je netwerk ###
Wanneer je stiekem net `h1 ping h2` hebt gedaan, kwam je tot de conclusie dat verkeer het nog niet deed.
Dat komt doordat er nog geen goede functionaliteit op de controller voor is.
Ga naar de CLI van de controller en activeer de `org.onosproject.fwd` app.
Initieer vervolgens een nieuwe ping tussen twee hosts via Mininet en *voilà*!

&nbsp;
### SDN in detail: App Limitaties ###
__Belangrijk__: _Vanaf nu heb je de extra bestanden nodig op de VM (in de home-folder)._

Nu gaan we wat gedetailleerder kijken naar hoe SDN werkt.
We springen daarbij gelijk in het diepe - vervolgens kan je zelf e.a. experimenteren.
We gaan ook gebruik maken van de GUI van ONOS.
Allereerst, zorg dat ONOS opgestart is in een terminal en dat de basis applicaties zijn geactiveerd.
Start vervolgens vanuit de home-folder een andere terminal waarin we Mininet gaan opstarten met onze eigen topologie:
```
sudo mn --mac --topo mytopo --custom triangle.py --controller remote,ip=127.0.0.1,port=6633 --switch ovsk,protocols=OpenFlow13
```
__Extra__: _`triangle.py` definieert een netwerk met drie switches in een driehoek met aan elke switch éen host. Benieuwd hoe? Open dan het bestand met een tekst-editor (bv. `gedit`). Je kunt ook zelf zo'n soort script schrijven en daarmee je eigen topologie definiëren._

De GUI van ONOS vinden we in een browser via de URL `http://localhost:8181/onos/ui/login.html`, en de inloggegevens `onos/rocks`.
Vervolgens zien we iets wat hierop lijkt:
![onos gui](/images/topo-1.png)

Neem de tijd om op deze pagina wat te experimenteren.
je kan op verbindingen en op switches klikken (ook op hosts zodra ze zijn verschenen) en de portnummers verschijnen.
Gebruik de `/` toets om het menu met sneltoetsen te open en nog meer opties te ontdekken.
Zorg bijvoorbeld dat `Host Visibility` aanstaat met de sneltoets `H`.

Activeer nu (als dat nog niet zo is) de app `org.onosproject.fwd` op de controller en voer in Mininet het commando `pingall` uit.
Terwijl je dit doet, __let op de GUI__.
Hoewel de pings *niet* succesvol zullen zijn, zal je wel de hosts zien verschijnen in de topologie.

__Pardon? Qué? De Pings doen het niet, waarom?__

Zoals gezegd, de switches zijn 'domme' apparaten die alleen maar hun zogenaamde flow table kunnen raadplegen.
Met Mininet kan je in de CLI de inhoud van de flow table opvragen, met het commando:
```
sh ovs-ofctl -O OpenFlow13 dump-flows s1
```
![flows](/images/flows.png)

In de ONOS CLI zijn commando's als `devices`, `hosts` en `flows` interessant. Probeer maar.

Zoals je in het plaatje kun zien, zegt een deel van de tweede regel `priority=4000, arp, actions=CONTROLLER:66535`.
Kortweg, houdt deze regel in dat als de switch een ARP-pakket tegenkomt, hij het gehele pakket moet doorsturen naar de controller, zodat die een beslissing kan nemen.
De controller probeert met behulp van ontvangen pakketten de topologie te ontdekken - dit is geïmplementeerd in de `org.onosproject.fwd` applicatie.
In topologieën zonder loops (cirkels) werkt deze app uitstekend en worden er als resultaat door de controller nieuwe regels in de flow tables geïnstalleerd zodat de switches voortaan weten wat ze moeten doen.
Maar in dit geval kan de controller geen beslissing maken en loopt het verkeer dus spaak.

&nbsp;
### SDN in detail: Experimenteer zelf ###
Gebruik de commando's en ervaring van het vorige gedeelte om te kijken wat er gebeurt met een simpelere topologie, zoals een netwerk met maar 1 switch en daaraan een aantal hosts.
Om even fris te starten, sluit de controller af (`logout`) en stop Mininet (`exit`). Voer daarnaast in de terminal waar je Mininet laat lopen het commando `sudo mn -c` uit.
Start vervolgens de controller opnieuw en start Mininet met het commando:
```
sudo mn --mac --topo single,4 --controller remote,ip=127.0.0.1,port=6633 --switch ovsk,protocols=OpenFlow13
```

Controlleer of de forwarding app nog geactiveerd is (verwachting is van wel), en doe nog eens een `pingall` of misschien leuker nog, een `h2 ping h3`.
Gebruik vervolgens de commando's van hierboven om uit te pluizen wat het resultaat is.


#### Wireshark: Onderzoek het OpenFlow verkeer ####
Onos gebruikt het OpenFlow protocol om flow rules te installeren op de Open vSwitches, maar in feite hebben we tot nu toe weinig van dit protocol gezien.
We kunnen dit verkeer onderzoeken met de packet-sniffer `Wireshark`.

Om het opstarten gemakkelijk te maken, raad ik aan om (als je dat nog hebt lopen) je Mininet netwerk te stoppen. Het is OK als de controller nog aanstaat.

Je kunt `Wireshark` het beste opstarten via een nieuwe terminal met het commando `sudo wireshark &`.
In de GUI die opent, start je een 'capture' op de `loopback:lo` interface.
Nu komt je in een volgend scherm, waar uiteindelijk alle pakketten verschijnen die 'gesnifft' worden. Omdat wij geïnteresseerd zijn in `OpenFlow` verkeer, raad ik het volgende 'filter' aan:
```
openflow_v4 and openflow_v4.type != ofpt_multipart_request and openflow_v4.type != ofpt_multipart_reply
```
_ik kies voor dit filter omdat, als de switches verbonden zijn met de controller, er veel onderling verkeer is zodat de controller op de hoogte blijft van de status van het netwerk. Dat is voor nu niet interessant. Wil je dit wel zien, verklein het filter dan naar alleen `openflow_v4`._

Start nu Mininet op.
In Wireshark zie je nu verschillende OpenFlow berichten langskomen, in volgorde dat ze heen en weer worden gestuurd.
Het interessants zijn de `HELLO`, `FEATURE_REQUEST` en `FEATURE_REPLY` en later ook de `FLOW_MOD`.
De eerste drie berichten zijn onderdeel van de zogenaamde OpenFlow 'handshake', waar de switch en controller een verbinding tussen elkaar opzetten.
De `FLOW_MOD` komt altijd van de controller af, en installeert een flow rule op een switch.
Dit bericht zul je zien zodra je twee hosts in Mininet met elkaar laat pingen.

__Extra__: _Je kan de inhoud van pakketten uitpluizen door te kijken naar de Packet Details - de Packet Bytes zijn minder interessant._


&nbsp;
### Even een stukje Context ###
Nu we van alles hebben gezien van met `Mininet`, `ONOS`, `OpenFlow` en `Wireshark`, en ongeveer weten hoe dingen in z'n gang gaan in een Software-Defined Netwerk, is het goed te herhalen wat we hebben gezien en hoe dat allemaal in elkaar past.
Dit kunnen we doen door te kijken naar de architectuur van ONOS:
![onos-architectuur](/images/onos-architecture.png)

Eigenlijk is de ONOS-implementatie de vormgeving van de gele, zwarte en groene laag:
De core van de controller ondersteunt aan de boven- en onderkant verschillende verbindingen met externe ‘dingen’.
Aan de onderkant is dat verbinding met netwerkapparatuur.
In deze tutorial is er gefocust op het OpenFlow protocol, dat gebruikt wordt om de flow tables van SDN-enabled switches, zoals Open vSwitch, te vullen.
Deze SDN-enabled switches hebben we in deze tutorial opgezet met behulp van Mininet.

De core implementeert de basis functionaliteit van de controller, maar uiteindelijk zullen de applicaties bovenop de controller bepalen hoe het netwerk functioneert.
Wij hebben hebben al één applicaties bekeken, namelijk Reactive L2 Forwarding en zullen dadelijk nog kijken naar Intent-based L2 Forwarding.
Er zijn er nog veel meer, want een netwerk moet veel meer kunnen doen dan alleen pakketten doorsturen.
De ONOS GUI is ook een voorbeeld van een applicatie!
Applicaties gebruiken de northbound interface (ofwel API’s) om hun eisen en wensen in het juiste format te gieten zodat de controller er iets mee kan.
Tegelijkertijd heeft de controller een ‘policy enforcement’ implementatie die er bijvoorbeeld voor zorgt dat de eisen die applicatie A geeft tegelijkertijd doorgevoerd kunnen worden als de eisen van applicatie B.
Conflicten tussen verschillende applicaties kunnen door de implementatie voor ‘conflict resolution’ opgelost worden.

En _last but not least_, alle applicaties zijn door middel van software geschreven - en dat maakt het software-defined networking!


&nbsp;
### SDN in detail: Intent Forwarding ###
In het vorige stuk kwam naar voren dat de forwarding app zijn limitaties heeft.
Nu gaan we een applicatie bekijken die onze problemen oplost!
Deze applicatie werkt met zogenaamde _Intents_.
Intents kunnen gezien worden als policy regels die wensen en eisen specificeren.
De controller berekent vervolgens hoe het verkeer moet lopen om aan deze wensen en eisen te voldoen.

Voor de zekerheid, verschoon Mininet door het af te sluiten (`exit`) en `sudo mn -c` te doen.
Verschoon ook de controller met de volgende commando's:
```
app deactivate org.onosproject.fwd
wipe-out please
```
_Vergeet geen_ __please__ _te zeggen bij de wipe-out. Anders luistert de controller niet!_

Start Mininet op met de `triangle.py` topology zoals eerder gedefinieert.
Wanneer de controller en Mininet weer zijn opgestart, ga in de ONOS GUI via het menu naar 'Applications'.
Hier kunnen we het `.oar` bestand toevoegen dat je hebt gedownload. (zie het plaatje hieronder)
`OAR` staat voor 'ONOS Applications aRchive'; in principe kun je elk zelf-geschreven applicatie ombouwen tot zo'n bestand zodat je deze kan toevoegen aan de controller.
Nogmaals: Dít is nu _software-defined_ networking.

![onos app toevoegen](/images/onos-applications.png)

__Extra__: _voer in de ONOS CLI `apps -s -a` uit om daar te zien dat de applicatie het doet._

Probeer nu in Mininet weer een `pingall`. Heb geduld, want de controller moet het een en al berkenen, maar als je het commando een tweede keer uitvoert hoort het allemaal te werken.

_So, what happened?_
Om te begrijpen wat er is gebeurd, bekijk in Mininet de flow table van een switch met:
```
sh ovs-ofctl -O OpenFlow13 dump-flows s1
```
en voet in de ONOS CLI het volgende commando in:
```
Intents
```

De uitkomst voor de Intent voor verkeer tussen Host 1 en Host 2 zie je hieronder:
![intent](/images/intent.png)

Zoals gezegd heeft de controller op basis van de Intent besloten hoe het verkeer moet lopen.
De Intents (zoals je ze ziet in de ONOS CLI) zijn vertaald naar flow rules (die je ziet m.b.v. Mininet).
Zoals je hierboven kan aflezen heeft deze Intent weinig 'constraints'; we willen verkeer tussen twee hosts en hebben geen verdere eisen.
Maar Intents kunnen heel veel constraints met zich meegeven, zoals je kan zien als je in de ONOS CLI het volgende commando uitvoer:
```
add-host-intent --help
```

De uitkomst is een hele lange lijst met opties die je kunt meegeven aan zelf gedefinieerde Intents.
En voor deze Intents hoef je helemaal niet na te denken over de route die het verkeer zal afleggen - dat rekenwerk zal de controller uitvoeren en vertalen naar flow rules voor de betrokken switches.
En dit is geïmplementeerd in de `ifwd` applicatie.

#### Experimenteer met Dynamische netwerken ####
De controller houdt te allen tijde het netwerk en de eisen (ofwel Intents) in de gaten.
Wanneer je een intent voor verkeer tussen Host 1 en Host 2 weg zou gooien met het commando:
```
remove-intent org.onosproject.ifw 00:00:00:00:00:01/None00:00:00:00:00:02/None
```
Dan is het resultat dat de controller de flow rules die bij deze Intent horen ook verwijderd.
En dat kan je weer zien in de flow tables van de betrokken switches:
![removal of intents](/images/remove-intents.png)

De verwijderde Intent kan je op twee manieren weer terugkrijgen.
allereerst door een ping te initiëren (maar dat is een saaie oplossing), ten tweede via de GUI.
In de pagina waar je de topologie ziet, kun je m.b.v. de Shift-knop de twee betreffende hosts aanklikken en dan verschijnt er de mogelijkheid om een 'host-to-host Intent' te creëren:
![topo for intents](/images/topo-intents.png)
De rechter knop toont 'Related Traffic': Omdat de Intent net verwijderd is, is dit resultaat leeg.
Hieronder zie je bijvoorbeeld wel related traffic tussen twee andere hosts.
De nieuwe Intent kan je toevoegen met de linker knop.
![topo for related paths](/images/related-paths.png)

__Extra__: _Je kunt ook een switch aanklikken, waarna er getoond wordt hoeveel flows er zijn geïnstalleerd voor de verschillende verbindingen. Gebruikt de icoontjes rechtsonder om nog meer te ontdekken!_

![topo for switches](/images/topo-flows.png)

&nbsp;

Intents houden ook rekening met de status van het netwerk.
Kijk maar eens in de flow tables en topologie wat er gebeurt als je een verbinding tussen twee switches (tijdelijk) uitzet in Mininet met het commando:
```
link s2 s3 down         ! use 'up' instead of 'down' to restore the link
```

&nbsp;
#### Try it all! Een Netwerk met verschillende routes ####
Als laatste is er een wat ingewikkeldere opgave.
De host-to-host Intents laten het rekenwerk aan de controller over en laat de controller dus de route van het verkeer bepalen.
Je kunt ook zogenaamde Point Intents gebruiken om specifiek door te voeren wat je wil dat er gebeurt als verkeer op een bepaalde port in een switch binnenkomt.
Zulke Intents voeg je toe in de ONOS CLI met het commando `add-point-intent`.

Probeer zelf eens te kijken hoever je komt en probeer de route tussen twee hosts via de switch te laten lopen die er eigenlijk niets mee te maken heeft.
Vergeet de `--help` optie niet.
Je kunt tijdens het toevoegen van de point Intents ook een capture doen in Wireshark.
Kijk maar wat er allemaal gebeurt!

Mocht je er niet uit komen, dan kan je altijd nog spieken bij [dit filmpje](https://www.youtube.com/watch?v=glkJaBvtqpA).
