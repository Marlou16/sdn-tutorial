# Introduction to SDN

Welcome to this tutorial where you will get to know Software Defined Networking.
Following this tutorial you will able to setup your own virtual environment and create a virtual network using `mininet` which is controlled by the `ONOS` SDN controller.
One can install a specific application on this controller which creates connectivity using `Intents`.
We will also spend some time on putting everything in the right context.

_You can use the available Powerpoint presentation to see how communication works in a traditional network and in a SDN network._

##### Assumed knowledge
You don't have to be a network expert to follow this tutorial; I am going to make you one!
Besides this, we are going to setup a virtual environment and work with the command line interface (CLI).
If you are not familiar with these things, don't be afraid to aks your friend the Internet.

![banner image](/images/tutorial-banner.png)

## Contents
1. [Preparation](#voorbereiding)
2. [Discover ONOS](#onos)
3. [Creating your network with Mininet](#mininet)
4. [SDN in detail: App Limitations](#sdn-1)
5. [The OpenFlow protocol in Wireshark](#wireshark)
6. [Putting things in Context](#context)
7. [SDN in detail: Intent Based Forwarding](#sdn-2)

&nbsp;
## Preparation <a name="voorbereiding"></a>
Before we can start, we need to setup our virtual environment.
For this, we are going to install a Virtual Machine which runs in VirtualBox.
VirtualBox you can download [here](https://www.virtualbox.org/wiki/Downloads), and the VM which we are going to extend you can download [here](https://github.com/mininet/mininet/wiki/Mininet-VM-Images).
This VM has already `Mininet` installed, but we are going to extend it giving it a GUI, web browser and an installation of the `ONOS` controller.

When you have imported the VM into VirtualBox, don't start this yet, but go to the VM settings.
Here, in the submenu for 'System', set the memory on (at least) 2048MB.
In the submenu for the 'Network', check whether Adapter 1 is on and set on NAT.
Then, when starting the VM, you will enter a terminal. This is all the VM has got.
You can login using `mininet/mininet`.
Then, in the terminal, execute the following commands:

install the GUI and VM Guest Additions (for better resolution):
```
sudo apt-get update
sudo apt-get install xinit lxterminal lxde-common lxsession openbox
sudo apt-get install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
```

We need `java(8)`:
```
sudo apt-get install python-software-properties software-properties-common
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer oracle-java8-set-default
```

install additional software: `Wireshark`, web browser and text-editor:
```
sudo apt-get install chromium-browser
sudo apt-get install gedit
sudo apt-get install Wireshark
```

For the next step you need the GUI of the VM (the GUI you just installed).
__On the VM, you open the GUI using the command `startx`.
Then, you can open a seperate terminal using the combination `Ctrl+Alt+T`__
If correct, you should be in the so-called 'home-folder' `/home/mininet`.
You can check where you are at any moment using the command `pwd`.

To get __ONOS__, at the VM visit [this site](https://wiki.onosproject.org/display/ONOS/Downloads) and download the 1.10.4 version in `tar.gz` format.
Then:
```
cd Downloads
tar -zxvf onos-1.10.4.tar.gz
mv onos-1.10.4 ~/
cd ..
```

If correct, you are now ready to go!
Also, keep in mind that you can also use this VM to play some more after this tutorial.

For the tutorial you need the files _triangle.py_ and _onos-app-ifwd-1.9.0-SNAPSHOT.oar_, which you can download from this GitHub repository.
However you get the files (for example in a `.zip` downloading from the site), eventually you need the files in the home-folder (which is, again, `/home/mininet`).

&nbsp;
## Discover ONOS (Open Network Operating System) <a name="onos"></a>
ONOS is an _open source_ controller, written in Java.
You can use the code for free, look into it and also edit it (on your own system).
Programmers from all over the world have collaborated on this software.
All documentation (and more tutorials/tips) can be found on their [wiki](https://wiki.onosproject.org/display/ONOS/Wiki+Home).

Let's start the controller.
You can achieve this by performing the following command from the home-folder:
```
sudo ./onos-1.10.4/apache-karaf-3.0.8/bin/karaf clean
```
__tip__: 'auto-complete' a folder-name using the TAB button.

If correct, a Command Line Interface (CLI) of the controller will start (_be patient_).
ONOS uses for this the tool `KARAF` - but we will not look into this tool in detail.

![onos cli](/images/onos-apps.png)

From the CLI you can manage the controller by performing different commands.
Using commands you can for example activate different applications, and you need these applications to indeed let the controller be of any use.
ONOS has a bunch of applications, of which we will activate some:
```
app activate org.onosproject.openflow
app activate org.onosproject.drivers
apps -s -a
```

If correct, when performing the last command, you will get the same list of apps as in the picture above.
If not, you should activate the missing apps seperately, because you will need them.

__Extra__: _Using the command `apps -s -a` the option `-s` lets you show a summary result and the `-a` means you are only interested in the activated apps. Using `apps --help`, you will get a list of all options for the `apps` command. In the ONOS CLI you can use `--help` after every command if you want to know some more._

You can shut down ONOS using `logout`.

&nbsp;
## Your own network using Mininet <a name="mininet"></a>
Nice, we have a SDN controller, but we can't do anything yet because we lack a network.
For this we will use the tool `Mininet`.
This tool is used to setup small networks which contain `Open vSwitches`.
An `Open vSwitch` is a typical SDN-switch: a 'stupid' switch which needs a controller to function.

*Open a new terminal (or tab)*. You can start Mininet using the following command:
```
sudo mn --topo tree,2,3 --controller remote,ip=127.0.0.1,port=6633 --switch ovsk,protocols=OpenFlow13
```

In short, this command does:
- create a network topology with `--topo`. Here, we build a 'tree' with depth 2 and 3 devices/hosts per layer.
- connect to a 'remote' controller on the given IP-adress and port we think we can reach it.
The `OpenFlow` protocol standardly uses port 6633 or 6533, and in this case the controller is located on our VM, which means we should use the *localhost* address 127.0.0.1.
- define switches as `Open vSwitch` using `OpenFlow 1.3`.
- use simple MAC addresses set with the option `--mac`.
As an example, the host with IP 10.0.0.1 gets the MAC  address 00:00:00:00:00:01.

![tree mininet](/images/mininet-start.png)

Via Mininet you also get a seperate CLI where you can execute different commands which steer the network, such as `h1 ping h2` or `xterm h1` (which opens a terminal for host 1) or `exit`.
When you want all information about your created network, use `dump`:

![dump mininet](/images/dump.png)

&nbsp;
#### Initiating Traffic

When trying `h1 ping h2`, you come to the conclusion that traffic isn't working.
This is because the required functionality is not installed on the controller!
Go to the controller CLI and activate the `org.onosproject.fwd` app.
Try initiating traffic again using Mininet and *voilá*!

&nbsp;
## SDN in detail: App Limitations <a name="sdn-1"></a>
__Important__: _From this moment you'll need the extra files on your VM (in the home-folder)_

Let's look at how SDN works in detail.
We will do this by jumping right in - after this, you can experiment some yourself.
We are also going to use the ONOS GUI.
First, make sure that ONOS is running in a terminal and check whether the basic apps are activated.
Then, from the home-folder, start an ew terminal where we will start a new Mininet (if the other one is still running, exit it) using a custom topology:
```
sudo mn --mac --topo mytopo --custom triangle.py --controller remote,ip=127.0.0.1,port=6633 --switch ovsk,protocols=OpenFlow13
```
__Extra__: _`triangle.py` defines a network with three switches which each connect a host. Curious how this works? Open the file using a text-editor (bv `gedit triangle.py`). You can also create your own script defining your own topology._

You can find the ONOS GUI in a web browser using the URL `http://localhost:8181/onos/ui/login.html`, logging in with `onos/rocks`.
Then, you should see something like this:
![onos gui](/images/topo-1.png)

Take the time to experiment some in the browser.
You can click on the links between the switches (or hosts when they appear) and investigate port numbers, for example.
Use the `/` button to get the menu with possibilities for options.
For example, make sure you use `H` to setup the `Host Visibility`.

If you have not done yet, activate the `org.onosproject.fwd` on the controller and perform a `pingall` in Mininet.
While waiting, __focus on the GUI__.
While the pings will not be successful, you will see the hosts appearing in the topology.

__Excuse me? Why won't the pings work?!__

As said, the switches are 'simple' devices which can only check their so-called flow-table.
Using the Mininet CLI you can ask for the content of these table, using the command:
```
sh ovs-ofctl -O OpenFlow13 dump-flows s1
```
![flows](/images/flows.png)

In the ONOS CLI, commands like `devices`, `hosts` en `flows` are interesting. Try!

As you can see in the image, a part of the second line states  `priority=4000, arp, actions=CONTROLLER:66535`.
In short, this line (flow rule) states that when the switch recieves a ARP-pakket, he should send it through to the controller to make a decision what to do.
Then, the controller will try to figure out what is best to do to discover the topology - this is implemented in the `org.onosproject.fwd` app.
In topologies without closed loops, this app works perfectly and as a result the controller will install new flow rules in the table to send packets through.
However, in this case, the controller can't make a decision, such that no new rules are installed.

&nbsp;
#### Try it yourself!
Use the commands and experience from the previous part to see what happens when you start Mininet with as simpler topology, such as one with only one switch with some hosts connected.
To start fresh, quit both the controller (`logout`) and Mininet (`exit`).
Also, in the terminal you are going to start Mininet, perform the command `sudo mn -c`.

Then, start Mininet with the following command:
```
sudo mn --mac --topo single,4 --controller remote,ip=127.0.0.1,port=6633 --switch ovsk,protocols=OpenFlow13
```

Check whether the forwarding app is still activated (we expect it is) and perform a `pingall`, or specifiek `h2 ping h3` (better).
Then, use commands from above to see what the result is in the flow table and in traffic response.

&nbsp;
## Wireshark: The OpenFlow Protocol <a name="wireshark"></a>
ONOS uses the OpenFlow protocol to install flow rull on the Open vSwitches, but up to now, we have not looked into this.
We can investigate this traffic with the packet-sniffer `Wireshark`.

To start easy, I recommend stopping Mininet. It is OK if ONOS is still running.

You can start `Wireshark` easily using a seperate terminal and performing the command `sudo wireshark &`.
A GUI will open, and you can start a 'capture' on the `looback:lo` interface.
You will enter a new screen where the packets you sniff appear.
Because we are (solely) interested in `OpenFlow` traffic, I recommend the following 'filter':
```
openflow_v4 and openflow_v4.type != ofpt_multipart_request and openflow_v4.type != ofpt_multipart_reply
```
_I choose this filter because, when the controller and switches are connected, a lot of OpenFlow traffic will be initiated by the controller to keep up to date about the status of the switches. For now, this is not interesting. If you are interesting, change the filter to only `openflow_v4`._

Start Mininet (topology doesn't matter).
In Wireshark now differnt OpenFlow packets come by, in the order they are sent.
Of most interest are the `HELLO`, `FEATURE_REQUEST` and `FEATURE_REPLY` (and later `FLOW_MOD`).
The first three packet types are part of the so-called OpenFlow 'handshake', where the controller and switch setup their connection.
The `FLOW_MOD` always comes from the controller, which installs a flow rule on the switch.
This will come by when you initiate a ping between two hosts in Mininet.

__Extra__: _You can also investigate the content of the OpenFlow packets by investigating the Packet Details - The Packet Bytes are of less interest._

&nbsp;
## Putting things in Context <a name="context"></a>
Now we have seen some things of `Mininet`, `ONOS`, `OpenFlow` and `Wireshark`, and partly know how it all works in a Software-Defined Network, let's repeat some things and put it in context.
We can do this by looking at the architecture of ONOS:
![onos-architectuur](/images/onos-architecture.png)

The actual ONOS-implementation is shown with the yellow, black and green layer:
the controller core supports different connections (protocols) at the upper and lower level to connect to external 'things'.
At the lower level, this will be network devices.
In this tutorial, we have focues on the OpenFlow protocol, which is used to fill the flow tables of SDN-enabled switches, such as Open vSwitch.
These SDN-enables switches can be setup in a virtualized manner using Mininet.

De controller core implemnts the basic functionality of the controller, but eventually, applications on top of the controller will mánage the network functionality.
We looked into one application, namely Reactive L2 Forwarding.
Later on, we will look into another one, Intent-based L2 Forwarding.
There are many other application, because a network should be able to do more than only forwarding packet.
The ONOS GUI is also an example of controller app!
Applications use the so-called northbound interface (also API's) to get their demands and date in the correct format to feed it to the controller.
At the same time, the controller will have a 'policy' enforcement' implementation which makes sure that the demands of app A don't clash with the demands of app B.
Soling conflicts between different applications is called 'conflict resolution'.

_Last but not least_, all applications are writting in software languages - this is what makes it really software-defined networking!

&nbsp;
## SDN in detail: Intent Based Forwarding <a name="sdn-2"></a>
In the previous part we saw that the first forwarding app had its limitations.
Now, we are going to focus on a better application.
This one works with _Intents_.
Intents can be seen as policy rules which specify certain demands.
The controller then calculates what to do to implement traffic which follow these demands.

To be sure, clean Mininet by exiting it (`exit`) and perform a `sudo mn -c`.
Also, clean the controller by performing in its CLI:
```
app deactivate org.onosproject.fwd
wipe-out please
```
_Don't forget to say_ __please__ _otherwise it won't listen!_

Start Minient with the `triangle.py` topology as is done before.
When the controller and Mininet are all set, go to the ONOS GUI and find in the menu the 'Applications' screen.
Here, we can add the `.oar` file which you have downloaded (see picture below).
`OAR` stands for 'ONOS Application aRchive'; in the context of software-defined networking, you can add every self-written application in such a file-format to the controller.

![onos app toevoegen](/images/onos-applications.png)

__Extra__: _In the ONOS CLI, perform `apps -s -a` uit to perform a check up._

In Mininet, now try a `pingall`. Be patient, because the controller has to do some calculations.
But, if correct, when performing the command for a second time, you will have a working network!

_So, what happened?_
To understand what happened, in Mininet, investigate the switch flow table using:
```
sh ovs-ofctl -O OpenFlow13 dump-flows s1
```
and in the ONOS CLI perform:
```
Intents
```

The result of the second command for traffic between Host 1 and Host 2 you see below:
![intent](/images/intent.png)

As stated, the controller has calculated what the switches need to do given the Intent.
The Intents as seen in the ONOS CLI are translated into flow rules you can see in the Mininet CLI.
As you can see, the Intent has a few 'constraints'; we just want traffic between two host, no further demands.
But, you can add a lot of constraints to an Intent, which you can investigate when performing:
```
add-host-intent --help
```

The result of the command is a long list of options.
You as a person, don't have to think about how the traffic needs to go - this calculation and translation will be performed by the controller.
This functionality is all implemented in the `ifwd` application.

&nbsp;
---
#### Experimenteer met Dynamische netwerken
The controller checks on the Intents and the status of the network any moment.
Would you remove an Intent for traffic between Host 1 and Host 2, using the following command:
```
remove-intent org.onosproject.ifw 00:00:00:00:00:01/None00:00:00:00:00:02/None
```
the result would be that the controller removes the flow rules which below to this Intent.
You can see this in the flow tables of the involves switches:
![removal of intents](/images/remove-intents.png)

You can get the removed Intent back in two ways.
First, you can initiate a ping between the two hosts (which is a boring option), secondly via the GUI.
On the screen showing the topology, you can select multiply hosts using the Shift-button, after which the option to install a 'host-to-host Intent' appears:
![topo for intents](/images/topo-intents.png)
The right buttong shows 'Related Traffic': But because we just deleted the Intent, this result is empty.
Below the result between two other hosts is shown.
With the left button you can create the Intent.
![topo for related paths](/images/related-paths.png)

__Extra__: _You can also click a switch, after which we see how many flows there are installed on the switch and on which links these flows work. Use the icons in the upper right corner to experiment some more!_

![topo for switches](/images/topo-flows.png)

&nbsp;

Intents also consider the status of the network.
You can look what happens in the flow tables and topology when you disable a link between two host (temporarely), by performing the following command in Mininet:
```
link s2 s3 down         ! use 'up' instead of 'down' to restore the link
```

&nbsp;
#### Try it all! Multiple routes in the network ####
We end with a more complicated task.
The host-to-host Intents will let the controller do all the calculations and planning.
But, if you want to decide for yourself how packets should travel through the network, you can use so-called Point Intents.
These Intents can be used to specify what to do with a packet when it enters a specific port on the switch.
You can add such Intents in the ONOS CLI using the command `add-point-intent`.

As an exercise, try to figure out whether you can setup traffic between two hosts which on one way travels across the extra switch, and on the way back takes the shortest route.
Don't forget your friend the `--help` option.
You can also perform a packet capture with Wireshark while adding these Intents to see what happens on OpenFlow level.
Just try some stuff! :)

Too difficult? The solution you see [here](https://www.youtube.com/watch?v=glkJaBvtqpA).
