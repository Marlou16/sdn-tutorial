# Introductie van SDN

Welkom bij deze tutorial waar je kennis zult maken met Software Defined Networking.
Na het volgen van deze tutorial heb je je eigen virtuele omgeving opgezet en zou je in staat moeten zijn om met `Mininet` een gevirtualiseerd netwerk op te zetten dat aangestuurd wordt door de `ONOS` (SDN) controller.
Op deze controller kan je een specifieke applicatie installeren die door middel van `Intents` het verkeer door het netwerk stuurt.
Ook zal deze tutorial alles in de juiste context te plaatsen.

_Deze tutorial wordt gebruikt tijdens de SDN workshop, waar extra uitleg wordt gegeven en wat dieper op het materiaal wordt ingegaan._
_Op deze GitHub pagina is er een kleine powerpoint beschikbaar waarin je kunt terugkijken hoe communicatie verloopt in een traditioneel netwerk en in een SDN netwerk._

##### Benodigde kennis #####
Je hoeft geen netwerk expert te zijn om dit te kunnen volgen; het is de bedoeling dat je je juist een beetje netwerk expert gáát voelen.
Daarnaast gaan we onze eigen virtuele omgeving opzetten en werken we veelal met de command line interface (CLI).
Ook hier hoef je niet heel erg gedreven in te zijn, maar elke ervaring is een voordeel.
Wees gedurende de tutorial vooral niet bang om random dingen te proberen en op te zoeken - het Internet is je vriend!

![banner image](/images/tutorial-banner.png)

## Inhoudsopgave
1. [Voorbereiding](#voorbereiding)
2. [Ontdek ONOS](#onos)
3. [Je eigen netwerk met Mininet](#mininet)
4. [Het OpenFlow Protocol](#sdn-1)
5. [Bestudeer OpenFlow met Wireshark](#wireshark)
6. [Even een stukje Context](#context)
7. [Next-level SDN: Intent Based Forwarding](#sdn-2)


&nbsp;
## Voorbereiding <a name="voorbereiding"></a>
Voordat we kunnen beginnen moeten we onze virtuele omgeving opzetten.
Dit doen we met de bestanden beschikbaar in de `vm` folder en de tool `Vagrant`, die de virtuele omgeving installeert en configureert. De VM is vervolgens te gebruiken met `VirtualBox`:
* Installeer [Vagrant](https://www.vagrantup.com/downloads.html) en [VirtualBox](https://www.virtualbox.org/wiki/Downloads),
* Installeer [Git](https://git-scm.com/downloads),
* Ga in de Explorer naar een gewenste locatie en open `Git Bash` door dit te kiezen als je op de rechtermuisknop drukt,
* In `Git Bash`, voer de volgende commando's uit:
    * `git clone https://github.com/Marlou16/sdn-tutorial`
    * `cd vm`
    * `vagrant up`

Tijdens de installatie wordt de VM al opgestart en zie je allerlei logging in je bash voorbijkomen.
Na de installatie is de VM klaar voor gebruik en kan je inloggen met `kpn/kpn`.

Belangrijk in de virtuele omgeving is de toestcombinatie `Ctrl+Alt+T`.
Hiermee open je een **terminal**.
Als je de eerste keer de VM gaat gebruiken, open een terminal en voer commando `./menu_favorites.sh` uit.
Hiermee maak je een aantal desktop icons direct beschikbaar, handig!


Voor de tutorial heb je ook nog de bestanden _triangle.py_ en _onos-app-ifwd-1.9.0-SNAPSHOT.oar_ nodig.
Het eerste bestand kan je vinden op de locatie `/home/kpn/mininet-topos`, het tweede bestand staat in je home-folder (`/home/kpn/`).

&nbsp;
## Ontdek ONOS (Open Network Operating System) <a name="onos"></a>
ONOS is een _open source_ controller, geschreven in Java.
Je mag de code gratis gebruiken, inzien en naar eigen believen aanpassen (op je eigen systeem).
Programmeurs over heel de wereld hebben hieraan meegewerkt.
Alle documentatie (en nog meer tutorials/tips) is te vinden op hun [wiki](https://wiki.onosproject.org/display/ONOS/Wiki+Home).

Laten we beginnen met het opstarten van de SDN-controller.
Dit kan door het volgende commando vanuit de home-folder uit te voeren:
```
sudo ./onos-1.10.4/apache-karaf-3.0.8/bin/karaf clean
```
__tip__: Je kan een folder-naam laten proberen 'auto-completen' met de TAB toets.

Als het goed is, start nu de Command Line Interface (CLI) van de controller op (_heb geduld!_).
ONOS gebruikt hiervoor de tool `KARAF` - daar gaan we in deze tutorial niet verder op in.

Vanaf de CLI kan je de controller besturen door verschillende commando's uit te voeren.
Hierdoor kan je bijvoorbeeld verschillende applicaties activeren.
Om de controller ook daadwerkelijk nuttige dingen te laten doen, is dit nodig - ONOS heeft een collectie aan functionaliteiten in apps gegoten die je aan/uit kunt zetten.
Voor de basis-applicaties, voer in de ONOS CLI de volgende commando's uit:
```
onos> app activate org.onosproject.openflow
onos> app activate org.onosproject.drivers
onos> apps -s -a
```
Als het goed is, wanneer je het laatste commando uitvoert, krijg je dezelfde lijst met geactiveerde applicaties te zien als op de afbeelding hieronder.
Zo niet, dan kan/moet je ze even los activeren.

![onos cli](/images/onos-apps.png)

__Extra__: _in het commando `apps -s -a` betekent de optie `-s` dat je een samenvattend resultaat wil zien en `-a` dat je alleen de geactiveerde applicaties wil zien. Wanneer je `apps --help` doet, krijg je een lijst van alle opties voor het commando `apps` te zien. In de ONOS CLI kan je `--help` gebruiken achter elk commando als je er meer over wilt weten._

Mocht het nodig zijn (*nu niet!*), dan kun je ONOS afsluiten met het commando `logout`.

&nbsp;
## Je eigen netwerk met Mininet <a name="mininet"></a>
Leuk, zo'n controller, maar we kunnen nog niets omdat we nog geen netwerk hebben!
`Mininet` is een tool waarmee je gemakkelijk een virtueel netwerk op kan zetten.
Deze tool wordt voornamelijk gebruikt om netwerkjes te creëren dat `Open vSwitches` bevat.
Een `Open vSwitch` is een typische SDN-switch: een 'domme' switch die een controller nodig heeft om te functioneren.
Om `Mininet` helemaal te ontdekken raad ik je aan (later nog eens) een van de beschikbare tutorials te volgen die je online kan vinden.

*Open een nieuwe terminal (of tabblad)*. Mininet kan je opstarten met het volgende commando:
```
sudo mn --topo tree,2,3 --controller remote,ip=127.0.0.1,port=6633 --switch ovsk,protocols=OpenFlow13 --mac
```

Kortweg doe je de volgende dingen met dit commando:
- Je kiest de topologie van het netwerk met `--topo`. In dit geval bouwen we een 'boom' structuur met diepte 2 en 3 devices/hosts per laag.
- We verbinden ons netwerk aan een controller de 'remote' (op een andere locatie) is, en geven daarbij een IP-adres en port mee waarop we de controller denken te kunnen bereiken.
Het `OpenFlow` protocol gebruikt standaard port 6633 of 6653, en in dit geval draait de controller op dezelfde computer dus kunnen we het *localhost* IP-adres 127.0.0.1 gebruiken.
- We definiëren de switches als `Open vSwitch` met `OpenFlow 1.3`.
- We zetten met `--mac` het gebruik van simpele MAC addressen aan.
Zo krijgt het IP-adres 10.0.0.1 een MAC 00:00:00:00:00:01.

![tree mininet](/images/mininet-start.png)

Via Mininet heb je toegang tot een aparte CLI waar je verschillende commando's kan voeren die acties op het netwerk uitvoeren, zoals `h1 ping h2` of `xterm h1` (opent een aparte terminal voor host 1) of `exit`.
Alle informatie wat betreft de verbindingen tussen de netwerk onderdelen vindt je met `links`.
Wanneer je alle informatie van het netwerk wil hebben, is het commando `dump` interessant:

![dump mininet](/images/dump.png)

&nbsp;
#### Verkeer over je netwerk
Wanneer je stiekem net `h1 ping h2` hebt gedaan (doe het anders nu), kwam je tot de conclusie dat verkeer het nog niet deed.
Dat komt doordat er nog geen goede functionaliteit op de controller voor is.
Ga naar de CLI van de controller en activeer de `org.onosproject.fwd` app.
```
onos> app activate org.onosproject.fwd
```
Initieer vervolgens een nieuwe ping tussen twee hosts via Mininet en *voilà*!

&nbsp;
#### De ONOS GUI
Wanneer we de ONOS controller gebruiken hebben we ook toegang tot een GUI waarin we de netwerk topologie zouden moeten kunnen zien.
De GUI van ONOS vinden we in een browser via de URL `http://localhost:8181/onos/ui/login.html`, en de inloggegevens `onos/rocks`.
Vervolgens zien we iets wat hierop lijkt:
![onos gui 1](/images/gui.png)

Neem de tijd om op deze pagina wat te experimenteren.
Je kan op verbindingen en op switches klikken (ook op hosts zodra ze zijn verschenen) en de portnummers verschijnen.
Gebruik de `/` toets om het menu met sneltoetsen te openen en nog meer opties te ontdekken.
Zorg bijvoorbeeld dat `Host Visibility` aanstaat met de sneltoets `H`.

_Wanneer je nog niet alle hosts ziet, probeer dan meer 'pings' uit in de Mininet CLI (bv. `pingall`).
Terwijl je dit doet, let op de GUI en je ziet zo de hosts verschijnen._

&nbsp;
## Het OpenFlow Protocol <a name="sdn-1"></a>
Nu je het hebt zien werken, je kennis hebt gemaakt met de controller en het netwerk, ben je vast en zeker benieuwd hóe het nu allemaal werkt!
Zoals te zien in de Powerpoint presentatie, gebruikt ONOS het OpenFlow protocol om zogenaamde 'flow rules' te installeren op de Open vSwitches van Mininet.
We hebben dit tot nu voor lief aangenomen, maar nu is het tijd om dit goed te bekijken!

#### Een kleiner netwerk
Om het allemaal wat makkelijker te maken, gaan we nu aan de slag met een simpelere netwerk topologie - eentje met een enkele switch met daaraan een aantal hosts.
Om opnieuw te beginnen, stop de controller (`logout`) en stop Mininet (`exit`).
Als extra, in de terminal waar je Mininet draaide, voer het commando `sudo mn -c` uit.

Je kunt ONOS opnieuw opstarten door in de terminal waar het eerst draaide het pijltje omhoog in te drukken.
Zo verschijnen je laatst gebruikte commando's.

Miniet start je nu op met het volgende commando:
```
sudo mn --mac --topo single,4 --controller remote,ip=127.0.0.1,port=6633 --switch ovsk,protocols=OpenFlow13
```

#### Flow tables
Zoals gezegd, de switches zijn 'domme' apparaten die alleen maar hun zogenaamde flow table kunnen raadplegen.
Met Mininet kan je in de CLI de inhoud van de flow table opvragen, met het commando:
```
mininet> sh ovs-ofctl -O OpenFlow13 dump-flows s1
```
![flows](/images/flows.png)

In de ONOS CLI zijn commando's als `devices`, `hosts` en `flows` interessant.
__Probeer maar.__
Gebruik de optie `-s` om de output behapbaar te maken.

Zoals je in het plaatje kun zien, zegt een deel van de tweede regel `priority=4000, arp, actions=CONTROLLER:66535`.
Kortweg, houdt deze regel in dat als de switch een ARP-pakket tegenkomt, hij het gehele pakket moet doorsturen naar de controller, zodat die een beslissing kan nemen.
De controller probeert met behulp van ontvangen pakketten de topologie te ontdekken - dit is geïmplementeerd in de `org.onosproject.fwd` applicatie.
In simpele topologieën waar wij tot nu toe mee werken, werkt deze app uitstekend en worden er als resultaat door de controller nieuwe regels in de flow tables geïnstalleerd zodat de switches voortaan weten wat ze moeten doen.

Als een voorbeeld, gegeven je nieuwe topologie, probeer een ping tussen twee hosts met `h1 ping h2 -c5`.
Wanneer de ping klaar is, voer dan nogmaals het commando uit in de Mininet CLI om de flow table te verkijgen.
Je zult zien dat er nieuwe regels geïnstalleerd zijn, zeer specifieke ook!
Je kunt andere pings tussen andere hosts gebruiken om te kijken of je de verschillen tussen de regels snapt.

_Let op: De geïnstalleerde flow rules blijven niet 'eeuwig' in de flow table staan. Dit is een van de limitaties van de app die we nu gebruiken. Initieer een nieuwe ping en de flow wordt weer geïnstalleerd._


&nbsp;
## Bestudeer OpenFlow met Wireshark <a name="wireshark"></a>
_Stop Mininet. ONOS kan blijven draaien._

ONOS gebruikt het OpenFlow protocol om flow rules te installeren op de Open vSwitches, maar in feite hebben we tot nu toe weinig van dit protocol gezien.
We kunnen dit verkeer onderzoeken met de packet-sniffer `Wireshark`.

Je kunt `Wireshark` het beste opstarten via een nieuwe terminal met het commando `sudo wireshark &`.
Wanneer de GUI zich opstart, _negeer de verschillende meldingen die langskomen (gewoon OK indrukken)_.
In de GUI die opent, start je een 'capture' op de `loopback:lo` interface.
Je kunt dit regelen in het onderstaande blok in het scherm:
![wireshark](/images/wireshark.png)

Nu kom je in een volgend scherm, waar uiteindelijk alle pakketten verschijnen die 'gesnifft' worden. Omdat wij geïnteresseerd zijn in `OpenFlow` verkeer, raad ik het volgende 'filter' aan:
```
openflow_v4 and openflow_v4.type != ofpt_multipart_request and openflow_v4.type != ofpt_multipart_reply
```
_ik kies voor dit filter omdat, zodra de switches verbonden zijn met de controller, er veel onderling verkeer is zodat de controller op de hoogte blijft van de status van het netwerk. Dat is voor nu niet interessant. Wil je dit wel zien, verklein het filter dan naar alleen `openflow_v4`._

Start nu Mininet op met de zelfde simpele topologie.
In Wireshark zie je nu verschillende OpenFlow berichten langskomen, in volgorde dat ze heen en weer worden gestuurd.
Het interessants zijn de `HELLO`, `FEATURE_REQUEST` en `FEATURE_REPLY` en later ook de `FLOW_MOD`.
De eerste drie berichten zijn onderdeel van de zogenaamde OpenFlow 'handshake', waar de switch en controller een verbinding tussen elkaar opzetten.
De `FLOW_MOD` komt altijd van de controller af, en installeert een flow rule op een switch.
Dit bericht zul je zien zodra je twee hosts in Mininet met elkaar laat pingen.

__Extra__: _Je kan de inhoud van pakketten uitpluizen door te kijken naar de Packet Details - de Packet Bytes zijn minder interessant._


&nbsp;
## Even een stukje Context <a name="context"></a>
Nu we van alles hebben gezien van met `Mininet`, `ONOS`, `OpenFlow` en `Wireshark`, en ongeveer weten hoe dingen in z'n gang gaan in een Software-Defined Netwerk, is het goed te herhalen wat we hebben gezien en hoe dat allemaal in elkaar past.
Dit kunnen we doen door te kijken naar de architectuur van ONOS:
![onos-architectuur](/images/onos-architecture.png)

Eigenlijk is de ONOS-implementatie de vormgeving van de gele, zwarte en groene laag:
De core van de controller ondersteunt aan de boven- en onderkant verschillende verbindingen met externe ‘dingen’.
Aan de onderkant is dat de verbinding met netwerkapparatuur.
In deze tutorial is er gefocust op het OpenFlow protocol, dat gebruikt wordt om de flow tables te vullen van SDN-enabled switches, zoals Open vSwitch.
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
## Next-level SDN: Intent Based Forwarding <a name="sdn-2"></a>
__Belangrijk__: _Vanaf nu heb je de extra bestanden nodig op de VM (in de home-folder)._

De Reactive L2 Forwarding app die we tot nu toe hebben gebruikt heeft zijn limitaties.
Een daarvan is dat flow rules maar een korte tijd worden opgeslagen in de flow tables.
Daarnaast, in wat ingewikkeldere topologieën klopt de berekening van de controller ook niet altijd, waardoor er helemaal geen flow rules worden geïnstalleerd.

Om te kijken wat ONOS nog meer kan, gaan we een nieuwe applicatie bekijken.
Hiervoor deactiveren we eerst de huidige functionaliteit:
```
onos> app deactivate org.onosproject.fwd
onos> wipe-out please
```
_Vergeet geen_ __please__ _te zeggen bij de wipe-out. Anders luistert de controller niet!_

Daarnaast starten we een ingewikkeldere, zelf gecreëerde Mininet topologie:
```
sudo mn --mac --topo mytopo --custom mininet-topos/triangle.py --controller remote,ip=127.0.0.1,port=6633 --switch ovsk,protocols=OpenFlow13
```
__Extra__: _`triangle.py` definieert een netwerk met drie switches in een driehoek met aan elke switch éen host. Benieuwd hoe? Open dan het bestand met een tekst-editor (bv. `gedit`). Je kunt ook zelf zo'n soort script schrijven en daarmee je eigen topologie definiëren._

In de ONOS GUI ziet de topologie er zo uit:
![onos-gui](/images/topo-1.png)


In de ONOS GUI, ga via het menu naar 'Applications'.
Hier kunnen we het `.oar` bestand toevoegen dat je hebt gedownload.
`OAR` staat voor 'ONOS Applications aRchive'; in principe kun je elk zelf-geschreven applicatie ombouwen tot zo'n bestand zodat je deze kan toevoegen aan de controller.
Nogmaals: Dít is nu _software-defined_ networking.
Zoals te zien in het plaatje hieronder, gebruik de '+' om de app te uploaden en druk daarna op play!

![onos app toevoegen](/images/onos-applications.png)

__Extra__: _voer in de ONOS CLI `apps -s -a` uit om daar te zien dat de applicatie het doet._

Probeer nu in Mininet weer een `pingall`. Heb geduld, want de controller moet het een en al berekenen, maar als je het commando een tweede keer uitvoert hoort het allemaal te werken.

_So, what happened?_
Onze nieuwe applicatie werkt met zogenaamde *Intents*.
Intents kunnen gezien worden als policy regels die wensen en eisen specificeren.
De controller berekent vervolgens hoe het verkeer moet lopen om aan deze wensen en eisen te voldoen.
Om te begrijpen wat er precies is gebeurd, bekijk in Mininet de flow table van een switch met:
```
mininet> sh ovs-ofctl -O OpenFlow13 dump-flows s1
```
en voer in de ONOS CLI het volgende commando in:
```
onos> intents
```

De uitkomst voor de Intent voor verkeer tussen Host 1 en Host 2 zie je hieronder:
![intent](/images/intent.png)

Zoals gezegd heeft de controller op basis van de Intent besloten hoe het verkeer moet lopen.
De Intents (zoals je ze ziet in de ONOS CLI) zijn vertaald naar flow rules (die je ziet m.b.v. Mininet).
Zoals je hierboven kan aflezen heeft deze Intent weinig 'constraints'; we willen verkeer tussen twee hosts en hebben geen verdere eisen.
Maar Intents kunnen heel veel constraints met zich meegeven, zoals je kan zien als je in de ONOS CLI het volgende commando uitvoert:
```
onos> add-host-intent --help
```

De uitkomst is een hele lange lijst met opties die je kunt meegeven aan zelf gedefinieerde Intents.
En voor deze Intents hoef je helemaal niet na te denken over de route die het verkeer zal afleggen - dat rekenwerk zal de controller uitvoeren en vertalen naar flow rules voor de betrokken switches.


&nbsp;
#### Experimenteer met Dynamische netwerken
De controller houdt te allen tijde het netwerk en de eisen (ofwel Intents) in de gaten.
Wanneer je een intent voor verkeer tussen Host 1 en Host 2 weg zou gooien met het commando:
```
onos> remove-intent org.onosproject.ifwd 00:00:00:00:00:01/None00:00:00:00:00:02/None
```
Dan is het resultaat dat de controller de flow rules die bij deze Intent horen ook verwijderd.
En dat kan je weer zien in de flow tables van de betrokken switches:
![removal of intents](/images/remove-intents.png)

De verwijderde Intent kan je op twee manieren weer terugkrijgen.
Allereerst door een ping te initiëren (maar dat is een saaie oplossing), ten tweede via de GUI.
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
mininet> link s2 s3 down         ! use 'up' instead of 'down' to restore the link
```
Zoals je zult zien, is communicatie nog steeds mogelijk omdat het een andere route neemt.
Wanneer de verbinding het weer doet (voer de `up` variant van het commando uit), dan zal je zien dat het verkeer nog steeds de alternative route neemt.
_Kun je uitleggen waarom?_


&nbsp;
#### Try it all! Een netwerk met verschillende routes ####
Als je denkt dat je het allemaal snapt, dan is er een laatste, wat ingewikkeldere opgave.
De host-to-host Intents laten het rekenwerk aan de controller over en laat de controller dus de route van het verkeer bepalen.
Je kunt ook zogenaamde Point Intents gebruiken om specifiek door te voeren wat je wil dat er gebeurt als verkeer op een bepaalde port in een switch binnenkomt.
Zulke Intents voeg je toe in de ONOS CLI met het commando `add-point-intent`.

Probeer zelf eens te kijken hoever je komt en probeer de route tussen twee hosts via de switch te laten lopen die er eigenlijk niets mee te maken heeft.
Vergeet de `--help` optie niet.
Je kunt tijdens het toevoegen van de point Intents ook een capture doen in Wireshark.
Kijk maar wat er allemaal gebeurt!

Mocht je er niet uit komen, dan kan je altijd nog spieken bij [dit filmpje](https://www.youtube.com/watch?v=glkJaBvtqpA).
