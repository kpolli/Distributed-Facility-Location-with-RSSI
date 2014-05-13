#include "Timer.h"
#include "ServerDist.h"


module ClientDistC @safe()
{
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface AMSend;
    interface Receive;
    interface Timer<TMilli>;
   // interface Timer<TMilli> as Timer0;
    interface Read<uint16_t>;
    interface Leds;
   // interface AMSend as RssiMsgSend;

  }
}
implementation
{
  message_t msg1;
  message_t sendBuf;
  bool sendBusy;
  bool report1;
  uint8_t size = 16;
  uint8_t i = 0;
  uint8_t report2;
  uint8_t report3;
  uint8_t report6;
  uint8_t tem =99;
  uint8_t report7 = 0;
  uint8_t minimum, minimum1, m2;
  uint8_t min5;
  npacket_t clientU, clientU1[2];

  npacket_t local;

  // Use LEDs to report various status issues.
  void report_problem() { call Leds.led0Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }
  void report_received() { call Leds.led2Toggle(); }


  event void Boot.booted() {
    clientU.starC1 = 0;
    clientU.id = TOS_NODE_ID;
    call RadioControl.start();
    if (call RadioControl.start() != SUCCESS)
      report_problem();
  }

  void startTimer() {
    call Timer.startPeriodic(1000);
  }

  event void RadioControl.startDone(error_t error) {
    startTimer();
  }

  event void RadioControl.stopDone(error_t error) {
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    npacket_t *omsg = payload;
    report_received();

if (omsg->masterID == 6 && omsg->id == TOS_NODE_ID ){
clientU1[0].masterID = omsg->masterID;
clientU1[0].starC1 = omsg->starC1;
clientU1[0].id = TOS_NODE_ID;
}

else if (omsg->masterID == 7 && omsg->id == TOS_NODE_ID){
clientU1[1].masterID = omsg->masterID;
clientU1[1].starC1 = omsg->starC1;
clientU1[1].id = TOS_NODE_ID;
}



   for (i = 0; i < 1; i++){ 
   if ((omsg->id == TOS_NODE_ID)){ 
     minimum = clientU1[0].starC1;
     minimum1 =  clientU1[0].masterID;
     m2 = i;
}
    for (i = 1; i < 2; i++){
      if (clientU1[i].starC1 < minimum){
     m2 = i;
     minimum = clientU1[m2].starC1;
     minimum1 =  clientU1[m2].masterID;

       }

    }


   clientU.starC1 = minimum;
   clientU.masterID = minimum1;
   clientU.receiveRequest = TRUE;
   clientU.id = TOS_NODE_ID;
	startTimer();

   }
 

   if ((omsg->id == TOS_NODE_ID && omsg->facility == TRUE))
      {
       	clientU.masterID = omsg->masterID;
	clientU.dist = omsg->dist;
       call Leds.led0On();
	startTimer();
      }

    return msg;
  }

  event void Timer.fired() {
	if (!sendBusy && sizeof clientU <= call AMSend.maxPayloadLength())
	  {

	    memcpy(call AMSend.getPayload(&sendBuf, sizeof(clientU)), &clientU, sizeof clientU);
	    if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof clientU) == SUCCESS)
	      sendBusy = TRUE;
		
	  }
	if (!sendBusy)
	  report_problem();
      
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
    if (error == SUCCESS)
      report_sent();
    else
      report_problem();

    sendBusy = FALSE;
  }

  event void Read.readDone(error_t result, uint16_t data) {
    if (result != SUCCESS)
      {
	data = 0xffff;
	report_problem();
      }
  }
}
