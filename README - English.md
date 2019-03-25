# Introduction to SDN

Welcome to this tutorial where you will get to know Software Defined Networking.
Here, you will able to setup your own virtual environment and create a virtual network using `mininet` which is controlled by the `ONOS` SDN controller.
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
4. [The OpenFlow Protocol](#sdn-1)
5. [Looking at OpenFlow using Wireshark](#wireshark)
6. [Putting things in Context](#context)
7. [Next-level SDN: Intent Based Forwarding](#sdn-2)

&nbsp;
## Preparation <a name="voorbereiding"></a>
Before we can start, we need to setup our virtual environment.
For this, you can use the files available in the `vm` folder and the tool `Vagrant`, which will spin up the virtual machine and configure it.
The VM can be used via `VirtualBox`:
* Install [Vagrant](https://www.vagrantup.com/downloads.html) en [VirtualBox](https://www.virtualbox.org/wiki/Downloads),
* Install [Git](https://git-scm.com/downloads),
* Find a preferred spot in your Explorer and open `Git Bash` using the right mouse button,
* In `Git Bash`, perform the following commands:
    * `git clone https://github.com/Marlou16/sdn-tutorial`
    * `cd vm`
    * `vagrant up`

Using the installation, the VM will start and all kinds of logging will appear in your bash.
After the installation you are ready to go and login with `kpn/kpn`.

Important in the VM is the combination `Ctrl+Alt+T`, which gives you a new **terminal**.
The first time you use the VM, open a terminal using these keys and perform `./menu_favorites.sh`.
This will give you some desktop icons of applications we are going to use.

For the tutorial you need the files _triangle.py_ and _onos-app-ifwd-1.9.0-SNAPSHOT.oar_, available in the `vm` folder of this repository.
On the VM, the first file can be find in the `/home/kpn/mininet-topos` folder, and the second in your home-folder `/home/kpn/`.

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

From the CLI you can manage the controller by performing different commands.
Using commands you can for example activate different applications, and you need these applications to indeed let the controller be of any use.
ONOS has a bunch of applications, of which we will activate some:
```
app activate org.onosproject.openflow
app activate org.onosproject.drivers
apps -s -a
```

If correct, when performing the last command, you will get the same list of apps as in the picture below.
If not, you should activate the missing apps seperately, because you will need them.

![onos cli](/images/onos-apps.png)

__Extra__: _Using the command `apps -s -a` the option `-s` lets you show a summary result and the `-a` means you are only interested in the activated apps. Using `apps --help`, you will get a list of all options for the `apps` command. In the ONOS CLI you can use `--help` after every command if you want to know some more._

Should it be necessary, you can shut down ONOS using `logout` (but you should _not_ do this now).

&nbsp;
## Your own network using Mininet <a name="mininet"></a>
Nice, we have a SDN controller, but we can't do anything yet because we lack a network.
For this we will use the tool `Mininet`.
This tool is used to setup small networks which contain `Open vSwitches`.
An `Open vSwitch` is a typical SDN-switch: a 'stupid' switch which needs a controller to function.

*Open a new terminal (or tab)*. You can start Mininet using the following command:
```
sudo mn --topo tree,2,3 --controller remote,ip=127.0.0.1,port=6633 --switch ovsk,protocols=OpenFlow13 --mac
```

In short, this command does:
- create a network topology with `--topo`. Here, we build a 'tree' with depth 2 and 3 devices/hosts per layer.
- connect to a 'remote' controller on the given IP-adress and port we think we can reach it.
The `OpenFlow` protocol standardly uses port 6633 or 6533, and in this case the controller is located on our VM, which means we should use the *localhost* address 127.0.0.1.
- define switches as `Open vSwitch` using `OpenFlow 1.3`.
- use simple MAC addresses set with the option `--mac`.
As an example, the host with IP 10.0.0.1 gets the MAC  address 00:00:00:00:00:01.

![tree mininet](/images/mininet-start.png)

Via Mininet you also get a seperate CLI where you can execute different commands which steer the
network, such as `h1 ping h2` or `xterm h1` (which opens a terminal for host 1) or `exit`.
When you want all information regarding the connections (links) you can get with the command `links`.
When you want all information about your created network, use `dump`:

![dump mininet](/images/dump.png)

&nbsp;
#### Initiating Traffic
When trying `h1 ping h2`, you come to the conclusion that traffic isn't working.
This is because the required functionality is not installed on the controller!
Go to the controller CLI and activate the `org.onosproject.fwd` app.
Try initiating traffic again using Mininet and *voilá*!

&nbsp;
#### The ONOS GUI
Using the ONOS controller, it is possible to look into the network topology using a GUI.
You can find the ONOS GUI in a web browser using the URL `http://localhost:8181/onos/ui/login.html`, logging in with `onos/rocks`.
Then, with this network, you should see something like this:

![onos gui 1](/images/gui.png)

Take the time to experiment some in the browser.
You can click on the links between the switches (or hosts when they appear) and investigate port numbers, for example.
Use the `/` button to get the menu with possibilities for options.
For example, make sure you use `H` to setup the `Host Visibility`.

&nbsp;
## The OpenFlow Protocol <a name="sdn-1"></a>
Now we have started our first network and seen that it works, you should be curious hów it works!
As we have seen in the Powerpoint presentation, ONOS uses the OpenFlow protocol to install flow rules on the Open vSwitches.
Up to now, we have not looked into this.
First we will look investigate flow tables, and after that we will investigate OpenFlow packages!

#### A simpler topology
For this purpose, we are going to work with a simpler topology.
To start fresh, quit both the controller (`logout`) and Mininet (`exit`).
Also, in the terminal you are going to start Mininet, perform the command `sudo mn -c`.

You can start ONOS in the terminal it was running before by pressing 'up', which gives you the last used commands.

You can start Mininet with the following command:
```
sudo mn --mac --topo single,4 --controller remote,ip=127.0.0.1,port=6633 --switch ovsk,protocols=OpenFlow13
```

#### Flow tables
As said, the switches are 'simple' devices which can only check their so-called flow-table.
Using the Mininet CLI you can ask for the content of these table, using the command:
```
sh ovs-ofctl -O OpenFlow13 dump-flows s1
```
![flows](/images/flows.png)

In the ONOS CLI, commands like `devices`, `hosts` en `flows` are interesting. __Try!__

As you can see in the image, a part of the second line states  `priority=4000, arp, actions=CONTROLLER:66535`.
In short, this line (flow rule) states that when the switch recieves a ARP packet, he should send it through to the controller to make a decision what to do.
Then, the controller will try to figure out what is best to do to discover the topology - this is implemented in the `org.onosproject.fwd` app.
In simple topologies such as those we are working with, this app works fine and as a result the controller will install new flow rules in the table to send packets through.

As an example, try a ping between two hosts with `h1 ping h2 -c5`.
When this ping is finished, perform again the command shown above to get the flow table.
This time, you will see new flow rules, which are very specific!
You can try pings between other hosts to see how the resulting flows differ.


## Looking at OpenFlow using Wireshark
_Stop Mininet. It is OK if ONOS is still running._

Wireshark is a so-called packet-sniffer, and can we use to investigate the actual OpenFlow traffic.
You can start `Wireshark` easily using a seperate terminal and performing the command `sudo wireshark &`.
_Disregard any messages that pop up (just press OK)._
A GUI will open, and you can start a 'capture' on the `looback:lo` interface.
You can do this in this block in the GUI:

![wireshark](/images/wireshark.png)

You will enter a new screen where the packets you sniff appear.
Because we are (solely) interested in `OpenFlow` traffic, I recommend the following 'filter':
```
openflow_v4 and openflow_v4.type != ofpt_multipart_request and openflow_v4.type != ofpt_multipart_reply
```
_I choose this filter because, when the controller and switches are connected, a lot of OpenFlow traffic will be initiated by the controller to stay up to date about the status of the switches. For now, this is not interesting. If you are interested, change the filter to only_ `openflow_v4`.

Start Mininet (topology doesn't matter).
In Wireshark now different OpenFlow packets come by, in the order they are sent.
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
## Next-level SDN: Intent Based Forwarding <a name="sdn-2"></a>
__Important__: _From this moment you'll need the extra files on your VM (in the home-folder).
Before continuing, exit Mininet and perform a clean-up with `sudo mn -c`.
It is OK if ONOS is still running._

The Reactive L2 Forwarding app we have investigated has some limitations.
One is that Flow Rules don't stay installed long in the flow tables.
Also, in some more complicated topologies, flow rules aren't installed at all because the controller can't cope with the calculations.

To see what ONOS can do more, we are going to work with a new application.
For this, firstly deactivate the forwarding application in the ONOS CLI:
```
app deactivate org.onosproject.fwd
wipe-out please
```
_Don't forget to say **please** otherwise it won't listen!_

And, we start with a more complicated, custom-made Mininet topology:
```
sudo mn --mac --topo mytopo --custom triangle.py --controller remote,ip=127.0.0.1,port=6633 --switch ovsk,protocols=OpenFlow13
```
__Extra__: _`triangle.py` defines a network with three switches which each connect a host. Curious how this works? Open the file using a text-editor (bv `gedit triangle.py`). You can also create your own script defining your own topology._

In the ONOS GUI, the topology will look like this:
![onos gui](/images/topo-1.png)

In the ONOS GUI, go find in the menu the 'Applications' screen.
Here, we can add the `.oar` file which you have downloaded.
`OAR` stands for 'ONOS Application aRchive'; in the context of software-defined networking, you can add every self-written application in such a file-format to the controller.
You use the '+' to upload the app, and then press play!

![onos app toevoegen](/images/onos-applications.png)

__Extra__: _In the ONOS CLI, perform `apps -s -a` uit to perform a check up._

In Mininet, now try a `pingall`. Be patient, because the controller has to do some calculations.
But, if correct, when performing the command for a second time, you will have a working network!

_**So, what happened?**_
Our new applications works with so-called _Intents_.
Intents can be seen as policy rules which specify certain demands.
The controller then calculates what to do to implement traffic which follow these demands.
To understand what exactly happened, in Mininet, investigate the switch flow table using:
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

&nbsp;
#### Experiment with Dynamic Networks
The controller checks on the Intents and the status of the network any moment.
Would you remove an Intent for traffic between Host 1 and Host 2, using the following command:
```
remove-intent org.onosproject.ifwd 00:00:00:00:00:01/None00:00:00:00:00:02/None
```
the result would be that the controller removes the flow rules which below to this Intent.
You can see this in the flow tables of the involved switches:
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

As you will see, even when the link is down, communication is still possible, but takes another route.
When the link is up again (by performing the `up` version of the command), you will see that the traffic still takes the alternative route.
_Can you explain why?_

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

Too much? The solution you see [here](https://www.youtube.com/watch?v=glkJaBvtqpA).
