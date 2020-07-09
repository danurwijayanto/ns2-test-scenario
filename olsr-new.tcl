if {$argc != 3} {
    puts "Example:ns olsr-new.tcl OLSR tcp_traffic_load_1 scene_traffic_load_1"
    exit
}

set par1 [lindex $argv 0]
set par2 [lindex $argv 1]
set par3 [lindex $argv 2]

set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
# set val(ifq) CMUPriQueue
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(ifqlen) 5
set val(nn) 5
set val(rp) $par1
set val(cp) $par2                       ;# connection pattern
set val(sc) $par3                       ;# scenario file
set val(stop) 200
set val(x) 1000
set val(y) 1000
set val(energymodel) EnergyModel
set val(initialenergy) 1000
#set val(seed) 1.0
# set opt(logenergy) "on"
# Antenna/OmniAntenna set X_ 0
# Antenna/OmniAntenna set Y_ 0
# Antenna/OmniAntenna set Z_ 1.5
# Antenna/OmniAntenna set Gt_ 1.0
# Antenna/OmniAntenna set Gr_ 1.0
# Phy/WirelessPhy set CPThresh_ 10.0
# Phy/WirelessPhy set CSThresh_ 1.559e-11
# Phy/WirelessPhy set RXThresh_ 3.652e-10
# Phy/WirelessPhy set Rb_ 2*1e6
# Phy/WirelessPhy set Pt_ 0.2818
# Phy/WirelessPhy set freq_ 914e+6
# Phy/WirelessPhy set L_ 1.0
# if {$val(seed) > 0} {
#     puts "Seeding Random number generator with $val(seed)\n"
#     ns-random $val(seed)
# }

# Mac/802_11 set RTSThreshold_  3000
# Mac/802_11 set basicRate_ 1Mb
# Mac/802_11 set dataRate_  2Mb

set ns_ [new Simulator]

set tracefd [open olsr-cbr-scenario-1.200.tr w]
$ns_ use-newtrace
$ns_ trace-all $tracefd

set namtrace [open olsr-cbr-scenario-1.200.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

set god_            [create-god $val(nn)]

#------------------------------
set chan_ [new $val(chan)]

$ns_ node-config    -adhocRouting $val(rp) \
                    -llType $val(ll) \
                    -macType $val(mac) \
                    -ifqType $val(ifq) \
                    -ifqLen  $val(ifqlen) \
                    -antType $val(ant) \
                    -propType $val(prop) \
                    -phyType $val(netif) \
                    -topoInstance $topo \
                    -channel $chan_ \
                    -energyModel $val(energymodel) \
                    -idlePower 0.7 \
                    -rxPower 1.0 \
                    -txPower 1.4 \
                    -sleepPower 0.01 \
                    -initialEnergy $val(initialenergy) \
                    -agentTrace ON \
                    -routerTrace ON \
                    -macTrace ON \
                    -wiredRouting OFF


for {set i 0} {$i < $val(nn) } {incr i} {
      	set node_($i) [$ns_ node]
      	$node_($i) random-motion 0 ;
}

puts "Loading connection patter"
source $val(cp)

puts "Loading scenario file"
source $val(sc)


for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ initial_node_pos $node_($i) 50
}


$ns_ at $val(stop).000000001 "puts \"NS EXITING...\"; $ns_ halt"
puts "Start Simulation..."
proc stop {} { 
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    exit 0
} 
$ns_ run

