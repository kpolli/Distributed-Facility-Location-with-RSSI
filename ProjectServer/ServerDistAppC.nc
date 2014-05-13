#include "message.h"

#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration ServerDistAppC { }
implementation
{
  components ServerDistC, MainC, ActiveMessageC, LedsC,
    new TimerMilliC(),
    new AMSenderC(AM_SERVERDIST), new AMReceiverC(AM_SERVERDIST), new DemoSensorC() as Sensor;  
  components BaseStationC;
  components ServerDistC as App;
  components PrintfC;

  ServerDistC.Boot -> MainC;
  ServerDistC.RadioControl -> ActiveMessageC;
  ServerDistC.AMSend -> AMSenderC;
  ServerDistC.Receive -> AMReceiverC;
  ServerDistC.Timer -> TimerMilliC;
  ServerDistC.Read -> Sensor;
  ServerDistC.Leds -> LedsC;


#ifdef __CC2420_H__
  components CC2420ActiveMessageC;
  App -> CC2420ActiveMessageC.CC2420Packet;
#elif  defined(PLATFORM_IRIS)
  components  RF230ActiveMessageC;
  App -> RF230ActiveMessageC.PacketRSSI;
#elif defined(PLATFORM_UCMINI)
  components  RFA1ActiveMessageC;
  App -> RFA1ActiveMessageC.PacketRSSI;
#elif defined(TDA5250_MESSAGE_H)
  components Tda5250ActiveMessageC;
  App -> Tda5250ActiveMessageC.Tda5250Packet;
#endif
  
  App-> BaseStationC.RadioIntercept[AM_SERVERDIST];
  
}
