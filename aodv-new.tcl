if {$argc != 3} {
    puts "Example:ns adhoc-new.tcl AODV cbr-50-10-8 scene-50-0-20"
    exit
}

set par1 [lindex $argv 0]
set par2 [lindex $argv 1]
set par3 [lindex $argv 2]

set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(ifqlen)     5
set val(rp)         $par1
set val(x)          1000
set val(y)          1000
set val(tr)         aodv-normal-cbr-scenario-1.150.tr               
set val(nn)         150
set val(cp)         $par2                       
set val(sc)         $par3                      
set val(stop)       200
set val(energymodel)    EnergyModel 
set val(initialenergy)  1000                   
set ns_             [new Simulator]            

$ns_ color 1 Red
$ns_ color 2 Blue

set tracefd         [open $val(tr) w]          
$ns_ use-newtrace
$ns_ trace-all $tracefd

set namtrace      [open aodv-normal-cbr-scenario-1.150.nam w]        
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set topo            [new Topography]            
$topo load_flatgrid $val(x) $val(y)

set god_            [create-god $val(nn)]       

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
                    -macTrace ON

for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i)   [$ns_ node]                 ;# create node based on node-config
    $node_($i) random-motion 0                  ;# disable random motion
}

puts "Loading connection patter"
source $val(cp)

puts "Loading scenario file"
source $val(sc)

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ initial_node_pos $node_($i) 50
}

$ns_ at $val(stop).000000001 "puts \"NS EXITING...\"; $ns_ halt"
puts "Start Simulation..."
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
}
$ns_ run

