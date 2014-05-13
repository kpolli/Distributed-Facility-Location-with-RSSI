configuration ClientDistAppC { }
implementation
{
  components ClientDistC, MainC, ActiveMessageC, LedsC,
    new TimerMilliC(),
    new AMSenderC(AM_SERVERDIST), new AMReceiverC(AM_SERVERDIST), new DemoSensorC() as Sensor;
    
  ClientDistC.Boot -> MainC;
  ClientDistC.RadioControl -> ActiveMessageC;
  ClientDistC.AMSend -> AMSenderC;
  ClientDistC.Receive -> AMReceiverC;
  ClientDistC.Timer -> TimerMilliC;
  //ClientDistC.Timer0 -> Timer0;
  ClientDistC.Read -> Sensor;
  ClientDistC.Leds -> LedsC;
   // ClientDistC.RssiMsgSend -> RssiMsgSender;
}
