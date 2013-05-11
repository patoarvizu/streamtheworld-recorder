@Grab(group='org.codehaus.groovy.modules.http-builder', module='http-builder', version='0.5.0-RC2')
import groovyx.net.http.RESTClient
import groovyx.net.http.HTTPBuilder

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

String callSign = validateCallSign(args[0])
println callSign

XmlSlurper xmlSlurper = new XmlSlurper();
String signalMetaData = getSignalMetaData(callSign);
println signalMetaData;
def signal = xmlSlurper.parseText(signalMetaData);
println signal

int recordMPlayer(String url, int time, String callSign)
{
	return 1;
}

int startMPlayer(String url)
{
	return 1;
}

String validateCallSign(String callSign)
{
	return callSign;
}

String getSignalMetaData(callSign)
{
	return '''
<live_stream_config version="1.5" xmlns="http://provisioning.streamtheworld.com/player/livestream-1.5">
<mountpoints>
<mountpoint>
  <status>
  <status-code>200</status-code>
  <status-message>OK</status-message>
  </status>
    <transports>
                     <transport>http</transport>
              </transports>
      <servers>
     <server sid="2473">
   <ip>2473.live.streamtheworld.com</ip>
   <ports>
        <port type="http">80</port>
        <port type="http">3690</port>
        <port type="http">443</port>
       </ports>
   </server>
      </servers>
        <mount>RG690</mount>
           <format>FLV</format>
    
    <bitrate>24000</bitrate>
    
         <media-format container="flv" cuepoints="stwcue"> 
                      <audio index="0" samplerate="22050" codec="mp3" bitrate="24000" channels="1"/>
                      </media-format>
        <authentication>0</authentication>
    <timeout>0</timeout>
    <send-page-url>0</send-page-url>
</mountpoint>
</mountpoints>
</live_stream_config>
'''
}