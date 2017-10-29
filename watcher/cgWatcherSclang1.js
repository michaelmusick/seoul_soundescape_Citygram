"use strict";

var execP   = require('child-process-promise').exec;
var request = require('request')

var server, cgNet, session;
		
var options = {
	runIntervalInSec : 5, // 15, update rate for watcher 
	startDelayInSec  : 1, // 10, start delay for watcher                 
	clearTerminal    : 60, // 10, terminal clear sec
};

session = {
	welcomeMessage : "Hello Citygrammer",
	port           : 8080, 
	userInfo       : {wifi: {ssid: null, pass: null}}, 
	maxConnections : 1,
	dir            : {
			home     : "/home/pi/citygram/rpiServer/",
			wpa_supp : "wpa_supplicant/",
			hostapd  : "/etc/hostapd/", 
		},
	files: {
		network: {
			hostapd: {
				os: "/etc/hostapd/hostapd.conf", 
				cg: "/home/pi/citygram/rpiServer/network/hostapd.conf.cg"},     // <---
			wpa_supp: {
				template: "wpa_supplicant.template"},
			userCredsCG: "/home/pi/citygram/rpiServer/network/userInfo.cg",   // <---
		}
	},	
	status         : {		 
		userInteraction: false,
		wpaStatusWithUserCreds: false,
		mode         : "AP", 
		userCreds    : { wifi: null, cg: null },
		network      : { ping: null},
		results      : { cmd: null, details: null }, 	
		roamNetIdx   : 0,
		roamCredsCG  : {id: null, pw: null, node: null},
		roamMode     : false,
		roamLoops    : 0
	},
	flags          : {user: {rescanRequest: false}},
	network        : {
		cgSSID   : "citygram",
		mac      : null,
		ip       : {
			static : "10.10.0.1", 
			dynamic: null
		},
		hostname : null,		 	
	},
	passwords: {
		AP: "citygrammer4:33",
	},	
	urls: {
		citygram: {
			url: "https://citygramsound.com", 
			port: 4347,
			streamer: "simpler.html",
			puller: "puller.html"},
		}		
};

var codeDir = '/home/pi/citygram/rpiServer/';

var cgCmd   = {
	wifiMode       : codeDir + 'wifiMode.sh' + ' ',
	modeSTA        : codeDir + 'wifiMode.sh' + ' ',
	staticMode     : codeDir + 'staticMode.sh' + ' ',
	scanWifi       : codeDir + 'scanWifi.sh' + ' ',
	scanWifiLooper : codeDir + 'scanWifiLooper.sh' + ' ',
	ping           : codeDir + 'ping.sh' + ' ',
	lsDirWPA       : 'ls  ' + codeDir + '/wpa_supplicant/*.conf',
	rmSuppWithName : 'rm  ' + codeDir + '/wpa_supplicant/',
};


class CG_NetworkTools {
	constructor(session){
		this.session  = session;	
	}

	initNetwork(msg){
		var that = this;		
		that.startSC();	                
	};


	run(){
		try{

			var processName = 'sclang';
			
			processNameRunning(processName).						
			then(isRunning=>{
				if (isRunning){
					console.log('   [CG] YES Running: ' + processName + ' Running');
					//killProcess('jackd', null, 0).catch(catcher).
					//then(r=>{killProcess('scsynth', null, 0)}).
					//catch(catcher);	
				}
				else{
					console.log('   [CG] NO Running: ' + processName + ' Running');		
						
					killProcess('jackd', null, 0).catch(catcher).
					then(r=>{killProcess('scsynth', null, 0)}).
					catch(catcher).
					then(r=>{execP("sclang")}).
					catch(catcher);	
				}
			})
			.catch(catcher)
		}
		
		catch(e){ console.log(e) }
	}

	startSC(){
		console.log(">>> startSC");		
		//execP("sclang");
		console.log("<<< startSC");	
	}	
};

systemInit(session);


function catcher(e){
	console.log(e);
}	
			
function systemInit(session){

	// CG network tools
	cgNet = new CG_NetworkTools(session);	
		
	cgNet.initNetwork();
	
	setTimeout(()=>{
		setInterval(()=>{
			cgNet.run(); 											
		}, options.runIntervalInSec*1000)	
	}, options.startDelayInSec*1000);
	
	return;
}

// check if CG updater running
function processNameRunning(processName){
	//console.log("\n>>> processNameRunning");
	console.log("ps aux | grep " + processName)
	
	return (
	execP("ps aux | grep " + processName).
	then(r=>{						
		return new Promise((res,rej)=>{
			try{
				var servers = r.stdout;
				var allLinesTemp = servers.split('\n');
				var allLines = [];
				
				// remove all empty arrays
				for (var k=0; k<allLinesTemp.length; k++)
					if(allLinesTemp[k] !=="")
						allLines.push(allLinesTemp[k]);
						
				//console.log("\n", allLines.length);
				//console.log("\n", allLines);				
				//console.log('\n-----------------------')
				
				var foundSclang = false;
				var thisLine;
				let pidTemp = [];
				
				for (var k=0; k<allLines.length; k++){
					thisLine = allLines[k].split('grep sclang');
					
					if(thisLine[0] != thisLine[0].split('sclang')){
						foundSclang = true;
						
						var temp = thisLine[0].split(" ");
						
						for (var j=1; j<temp.length; j++){
							if (temp[j] !== ""){
								pidTemp.push(temp[j]);
								break;
							}
						}																								
						break;
					}
				}
				
				res(pidTemp);
			}catch(e){
				rej(e)	
			}
			//console.log("<<< processNameRunning");
		})	
	}).
		catch((e)=>{console.log(e); console.log("<<< processNameRunning")}).
	then(pids=>{
		var running = false;

		try{				
			//console.log("   [CG] CG Server PS: ", pids);
			//console.log("   [CG] num of pids: ", pids.length);
							
			if (pids.length>0)
				running = true;
			else
				running = false;

			return new Promise((res, rej)=>{
				try{res(running)}catch(e){rej(e)};
					//console.log("<<< processNameRunning")
				})				
		}catch(e){
			return new Promise((res, rej)=>{
				try{res(running)}catch(e){rej(e)};
			})}
		})			
	)
}	


// only one instance alllowed
function killExistingWatcher(){
	//console.log("\n>>> killExistingWatcher");
	return (
	execP("ps aux | grep 'cgWatcher.js'").
	then(r=>{						
		return new Promise((res,rej)=>{
			try{
				var servers = r.stdout;
				var allLinesTemp = servers.split('\n');
				var allLines = [];
				
				// remove all empty arrays
				for (var k=0; k<allLinesTemp.length; k++)
					if(allLinesTemp[k] !=="")
						allLines.push(allLinesTemp[k]);
						
				//console.log("\n", allLines.length);
				//console.log("\n", allLines);	
				//console.log('\n-----------------------')
				let pidTemp = [];
				
				for (var k=0; k<allLines.length; k++){
					let thisLine = allLines[k].split('node');
					
					if (thisLine.length>1){
						
						var temp = allLines[k].split(" ");
						
						for (var j=1; j<temp.length; j++){
							if (temp[j] !== ""){
								pidTemp.push(temp[j]);
								break;
							}
						}													
					}
				}
				
				console.log(pidTemp);
				var pidKillList = [];
				
				if (pidTemp.length > 1){
					for (var k=0; k<(pidTemp.length-1); k++)
						pidKillList.push(pidTemp[k]);
				}
					
				//console.log('-----------------------\n')
				
				var pid = [];
				if (allLines.length>3){
					for (var k=0; k<allLines.length-3; k++){

						var temp = allLines[k].split(" ");
						
						for (var j=1; j<temp.length; j++){
							if (temp[j] !== ""){
								pid.push(temp[j]);
								break;
							}
						}						
					}
				}
				//console.log(allLines);
				//console.log(pid);
				res(pidKillList);
			}catch(e){
				rej(e)	
			}
			//console.log("<<< killInstanceOf");
		})	
	}).
		catch((e)=>{console.log(e); console.log("<<< check if I exist")}).
	then(pids=>{
		try{				
			console.log("   [CG] pids to kill", pids);
			console.log("   [CG] num of pids to kill", pids.length);
			
			if (pids.length>0){
				var cmd = "";
				
				for (var k=0; k<pids.length; k++){
					cmd = cmd + " " + pids[k];
				} 						
				
				cmd = "kill -9 " + cmd;
				console.log(cmd)
				return execP(cmd);
			}									
		}catch(e){
			return new Promise((res, rej)=>{
				try{res(null)}catch(e){rej(e)};
			})}
	
		return new Promise((res, rej)=>{
			try{res(null)}catch(e){rej(e)};
				console.log("<<< killInstanceOf")
			})
		})			
	)
}


// killProcess('chromium-browser', null, 0)
function killProcess(grepStr, splitStr, self){
		console.log("\n>>> killProcess" + grepStr);
		return (
		execP("ps aux | grep " + grepStr).
		then(r=>{						
			return new Promise((res,rej)=>{
				try{
					var servers = r.stdout;
					var allLinesTemp = servers.split('\n');
					var allLines = [];
					
					// remove all empty arrays
					for (var k=0; k<allLinesTemp.length; k++)
						if(allLinesTemp[k] !=="")
							allLines.push(allLinesTemp[k]);
							
					//console.log("\n", allLines.length);
					//console.log("\n", allLines);
					
					let pidTemp = [];
										
					for (var k=0; k<allLines.length; k++){
						let thisLine;
						
						thisLine = allLines[k].split('grep');
						// ignore grep as it is basically self 	
						if (thisLine.length >1)
							continue;
						
						thisLine = allLines[k].split(grepStr);
						
						console.log(thisLine.length>1)
						
						if (thisLine.length>1){							
							var temp = allLines[k].split(" ");
							
							for (var j=1; j<temp.length; j++){
								if (temp[j] !== ""){
									pidTemp.push(temp[j]);
									break;
								}
							}													
						}
					}
					
					console.log('kill ' + pidTemp)
					console.log(pidTemp);

					if (pidTemp.length > 0)
						res(pidTemp[0])
					else
						res(null);
				}catch(e){
					rej(e)	
				}
				console.log("<<< killProcess " + grepStr);
			})	
		}).
			catch((e)=>{console.log(e); console.log("<<< killProcess " + grepStr)}).
		then(pid=>{
			try{				
				//console.log("   [CG] pid to kill: ", pid);
				
				if (pid !=null){
					let cmd = 'kill -9 ' + pid;
					
					console.log(cmd);
					return execP(cmd);
				}									
			}catch(e){
				return new Promise((res, rej)=>{
					try{res(null)}catch(e){rej(e)};
				})}
		
			return new Promise((res, rej)=>{
				try{res(null)}catch(e){rej(e)};
				console.log("<<< killProcess " + grepStr)})
			})			
		)
	}

function run(){
	try{
		initSystem();		

		var processName = 'sclang';
		
		processNameRunning(processName).						
		then(isRunning=>{
			if (isRunning){
				console.log('   [CG] YES Running: ' + processName + ' Running');
				//killProcess('jackd', null, 0).catch(catcher).
				//then(r=>{killProcess('scsynth', null, 0)}).
				//catch(catcher);	
			}
			else{
				console.log('   [CG] NO Running: ' + processName + ' Running');		
					
				killProcess('jackd', null, 0).catch(catcher).
				then(r=>{killProcess('scsynth', null, 0)}).
				catch(catcher).
				then(r=>{execP("sclang")}).
				catch(catcher);	
			}
		})
		.catch(catcher)
	}
	
	catch(e){ console.log(e) }
}
