/**
* CG Bridge Info
*
* https://citygramsound.com:4347/puller/index.html?autostart=true&playmode=birth&filter=0&onlyavg=false
*
* https://citygramsound.com:4347/indexA1.html
*
*/


n = NetAddr("127.0.0.1", 9999);
OSCdef(\test, {|msg, time, addr, recvPort| msg.postln; addr.postln; recvPort.postln;}, '', n); // def style

n.sendMsg('/', "der")


// Current method for getting data from CG_Bridge
thisProcess.openUDPPort(9999); // open UDP port to listen to OSC
(
f = { |msg, time, replyAddr, recvPort|
    if(msg[0] != '/status.reply') {
        "At time %s received message % from % on port%\n".postf( time, msg, replyAddr, recvPort )
    }
};
thisProcess.addOSCRecvFunc(f);
);
thisProcess.removeOSCRecvFunc(f);


// timestamp from rsd1
1385917359



OSCdef.new('test', {|args| args.postln}, '', n )