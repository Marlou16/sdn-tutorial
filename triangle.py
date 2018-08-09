"""
Adding the 'topos' dict with a key/value pair to generate our newly defined
topology enables one to pass in '--topo=mytopo' from the command line.
"""

from mininet.topo import Topo

class MyTopo( Topo ):
    "Simple topology example."

    def __init__( self ):
        "Create custom topo."

        # Initialize topology
        Topo.__init__( self )

        # Add hosts and switches
        host1 = self.addHost( 'h1' )
        host2 = self.addHost( 'h2' )
	host3 = self.addHost( 'h3' )
        leftSwitch = self.addSwitch( 's1' )
        rightSwitch = self.addSwitch( 's2' )
	upperSwitch = self.addSwitch( 's3' )

        # Add links
        self.addLink( host1, leftSwitch )
	self.addLink( host2, rightSwitch )
	self.addLink( host3, upperSwitch )
        self.addLink( leftSwitch, rightSwitch )
	self.addLink( leftSwitch, upperSwitch )
        self.addLink( upperSwitch, rightSwitch )

topos = { 'mytopo': ( lambda: MyTopo() ) }
