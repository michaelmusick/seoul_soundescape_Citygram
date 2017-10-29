"use strict";

// Does one main thing:
// (1) make sure that sclang process is alive
// (2) if not running, kill jackd, scsynth if exists 
// (3) restart sclang

/*
Bright = "\x1b[1m"
Dim = "\x1b[2m"
Underscore = "\x1b[4m"
Blink = "\x1b[5m"
Reverse = "\x1b[7m"
Hidden = "\x1b[8m"

FgBlack = "\x1b[30m"
FgRed = "\x1b[31m"
FgGreen = "\x1b[32m"
FgYellow = "\x1b[33m"
FgBlue = "\x1b[34m"
FgMagenta = "\x1b[35m"
FgCyan = "\x1b[36m"
FgWhite = "\x1b[37m"

BgBlack = "\x1b[40m"
BgRed = "\x1b[41m"
BgGreen = "\x1b[42m"
BgYellow = "\x1b[43m"
BgBlue = "\x1b[44m"
BgMagenta = "\x1b[45m"
BgCyan = "\x1b[46m"
BgWhite = "\x1b[47m"
*/

// TO DO: (2.1) go to known SSID and then pull
var execP     = require('child-process-promise').exec;
const restart = require('make-it-restart')

var codeDir     = '/home/pi/citygram/rpiServer/';

var updaterRunning = false;
var liveMode       = false;
var fontColor      = "\x1b[33m";

var options = {
	runIntervalInSec : 5, // 15, update rate for watcher 
	startDelayInSec  : 30, // 10, start delay for watcher                 
	clearTerminal    : 60, // 10, terminal clear sec
};

// Update restarter
let cgUpdaterRestart = restart({
		script: codeDir +'cgServerRpiUpdater.js',
		initRun: false,
		env: {
				NODE_ENV: 'Citygram RPI Updater'
		}
});

//function cgUpdaterRestart(){
//	console.log('RESTART FUNCTIOn')
//}

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

function initSystem(){
  console.log('\n')
  console.log('---------------------------------------')
  console.log('           cgWatcherSclang.js');
  console.log('---------------------------------------') 
  console.log('\n')

	updaterRunning = false;	
}

function pull(){
	return new Promise((resolve, reject)=>{
		try{
			//console.log('\n>>> pull()')
			execP('sudo git -C ' + codeDir + ' pull').
			then(r=>{
				try{
					resolve(r.stdout)
				}catch(e){
					reject(e);
				}
			}).catch(e=>{reject(e)})	
		}
		catch(e) { reject(e) }
			//console.log('<<< pull()')
	});
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

function catcher(e){
	console.log(e);
}	

// START
killExistingWatcher();

// LOOP
setTimeout(()=>{
	setInterval(()=>{
		run(); 											
	}, options.runIntervalInSec*1000)	
}, options.startDelayInSec*1000);


