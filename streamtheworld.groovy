@Grab(group='org.codehaus.groovy.modules.http-builder', module='http-builder', version='0.6')
import groovyx.net.http.HTTPBuilder
import static groovyx.net.http.Method.GET
import static groovyx.net.http.ContentType.TEXT

println "Starting"
if (args.length < 1)
{
	println 'usage: station callsign must be the first argument'
	System.exit(1)
}
	
if (args[0] == "radioacir")
{
	if (args.length >= 2 && args[1] == "r")
	{
		if(args.length == 3)
		{
			println "record with time"
			System.exit(recordMPlayer("http://76.73.20.18:8230/", Integer.parseInt(args[2]), "radioacir"))
		}
		else
		{
			println "record with default time"
			System.exit(recordMPlayer("http://76.73.20.18:8230/", 60, "radioacir"))
		}
	}
	println "start"
	System.exit(startMPlayer("http://76.73.20.18:8230/"))
}
String callSign = args[0];
XmlSlurper xmlSlurper = new XmlSlurper();
String signalMetaData = getSignalMetaData(callSign);
def liveStreamConfig = xmlSlurper.parseText(signalMetaData);
String url = createURL(liveStreamConfig, callSign);
println "URL: ${url}"
if (args.length >= 2 && args[1].equals("r"))
{
    if(args.length == 3)
        System.exit(recordMPlayer(url, Integer.parseInt(args[2]), callSign));
    else
        System.exit(recordMPlayer(url, 60, callSign));
}
else
{
    println "Start"
    System.exit(startMPlayer(url));
}

int recordMPlayer(String url, int time, String callSign)
{
    //p = subprocess.Popen(['mplayer', location, '-forceidx', '-dumpstream', '-dumpfile', datetime.datetime.now().strftime("%y-%m-%d-%H-%M") + '-' + callsign + '.mp3'])
    println "mplayer ${url} -forceidx -dumpstream -dumpfile " + (new Date().format("yy-MM-dd-HH-mm")) + "-${callSign}.mp3"
    String date = new Date().format("yy-MM-dd-HH-mm");
    Process mPlayerProcess = "mplayer ${url} -forceidx -dumpstream -dumpfile ${date}-${callSign}.mp3".execute();
    System.sleep(time * 1000)
	return mPlayerProcess.exitValue();
}

int startMPlayer(String url)
{
	Process mPlayerProcess = "mplayer ${url}".execute();
    mPlayerProcess.waitFor();
    return mPlayerProcess.exitValue();
}

String getSignalMetaData(callSign)
{
    HTTPBuilder httpBuilder = new HTTPBuilder("http://playerservices.streamtheworld.com/api/livestream?version=1.5&mount=${callSign}&lang=en");
    def metaData = httpBuilder.get(path : "/api/livestream", contentType: TEXT, query : [version : 1.5, mount : callSign, lang : "en"], headers : [Accept : 'application/xml'])
    return metaData.text;
}

String createURL(def liveStreamConfig, String callSign)
{
    def mountpoint = liveStreamConfig.mountpoints.mountpoint
	checkStatus(mountpoint)
    String protocol = mountpoint.transports.transport;
    String ip = mountpoint.servers.server.ip;
    String port = liveStreamConfig.mountpoints.mountpoint.servers.server.ports.port[0];
    return protocol + "://" + ip + ":" + port + "/" + callSign;
}

void checkStatus(def mountpoint)
{
    if(mountpoint.status."status-code" != "200")
		throw new RuntimeException("Error loading stream: " + mountpoint.status."status-message")
}