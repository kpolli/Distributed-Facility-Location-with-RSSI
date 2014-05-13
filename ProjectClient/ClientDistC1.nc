#include "Timer.h"
#include "ServerDist.h"

module ClientDistC @safe()
{
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface AMSend;
    interface Receive;
    interface Receive as Receive1;
    interface Timer<TMilli>;
    interface Read<uint16_t>;
    interface Leds;

  }
}
implementation
{
  message_t sendBuf;
  bool sendBusy;
  bool report1;
  uint8_t size = 16;
  uint8_t i = 0;
  uint8_t report2;
  uint8_t report3;
  uint8_t report6;
  uint8_t tem =999;
  uint8_t report7 = 0;
  uint8_t minimum;
  npacket_t clientU, clientU1[1];

  // Use LEDs to report various status issues.
  void report_problem() { call Leds.led0Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }
  void report_received() { call Leds.led2Toggle(); }


  event void Boot.booted() {
//   clientU1[0].id = TOS_NODE_ID;
 //  clientU1[0].dist = 0;
   clientU1[0].starC1 = 100;
//   clientU.receiveRequest = FALSE;
    if (call RadioControl.start() != SUCCESS)
      report_problem();
  }

  void startTimer() {
    call Timer.startPeriodic(250);
    //reading = 0;
  }

  event void RadioControl.startDone(error_t error) {
    startTimer();
  }

  event void RadioControl.stopDone(error_t error) {
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    npacket_t *omsg = payload;
    report_received();
     //if (omsg->id == 1)
       // call Leds.led0On(); 
     //if (omsg->masterID == 6)
       // call Leds.led0On(); 



for (i=0; i<1;i++){
if (omsg->masterID != tem){
clientU1[i].id = omsg->id;
tem = omsg->id;
clientU1[i].dist = omsg->dist;
clientU1[i].receiveRequest = omsg->receiveRequest;
clientU1[i].facility = omsg->facility;
clientU1[i].masterID = omsg->masterID;
clientU1[i].starC1 = omsg->starC1;
}
}



   //for (i = 0; i < 1; i++){ 
   if ((omsg->id == TOS_NODE_ID && omsg->starC1 < clientU1[i].starC1)){
   for (i = 0; i < 1; i++)  
     minimum = omsg->starC1;
    clientU1[i + 1].starC1 = omsg->starC1;
   //call Leds.led0On();
    for (i = 1; i < 1; i++){
      if (omsg->starC1 < minimum){
     minimum = omsg->starC1;
       }
    }
   clientU.starC1 = minimum;
   clientU.masterID = omsg->masterID;
   clientU.receiveRequest = TRUE;
   //call Leds.led0On();
   }
 

    // if (omsg->id == 1)
      //  call Leds.led0On();         
 
   if ((omsg->id == TOS_NODE_ID && omsg->facility == TRUE))
      {
       	clientU.masterID = omsg->masterID;
	clientU.dist = omsg->dist;
       call Leds.led0On();
	startTimer();
      }

    return msg;
  }

  /* At each sample period:
     - if local sample buffer is full, send accumulated samples
     - read next sample
  */
  event void Timer.fired() {
    //if (reading == NREADINGS)
	if (!sendBusy && sizeof clientU <= call AMSend.maxPayloadLength())
	  {
	    // Don't need to check for null because we've already checked length
	    // above
	    memcpy(call AMSend.getPayload(&sendBuf, sizeof(clientU)), &clientU, sizeof clientU);
	    if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof clientU) == SUCCESS)
	      sendBusy = TRUE;
		
	  }
	if (!sendBusy)
	  report_problem();

//	reading = 0;
	/* Part 2 of cheap "time sync": increment our count if we didn't
	   jump ahead. */
      
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
