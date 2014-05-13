#include "Timer.h"
#include "ServerDist.h"

#include "ApplicationDefinitions.h"
#include "printf.h"
//#include "RssiDemoMessages.h"

module ServerDistC @safe()
{
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface AMSend;
    interface Receive;
    interface Timer<TMilli>;
    interface Read<uint16_t>;
    interface Leds;
}
    uses interface Intercept as RssiMsgIntercept;

#ifdef __CC2420_H__
  uses interface CC2420Packet;
#elif defined(TDA5250_MESSAGE_H)
  uses interface Tda5250Packet;    
#else
  uses interface PacketField<uint8_t> as PacketRSSI;
#endif 

  }


implementation
{
  message_t sendBuf;
  bool sendBusy;
  bool report1 = FALSE;
  uint16_t connectclientB = 0; /* B* */
  uint16_t connectclientB1 = 0; /* B */
  uint16_t size = 16;
  uint16_t cf;
  uint16_t i = 0;
  uint16_t j = 0;
  npacket_t sendC;
  uint16_t report2; 
  uint16_t report5 = 0;
  uint16_t temp = 0;
  uint16_t temp2, temp3;
  uint16_t temp4 = 9999;
  uint16_t temp8;
  uint16_t getRssi(message_t *msg);

  npacket_t clientC[3], clientU[3], clientB[3];

  // Use LEDs to report various status issues.
  void report_problem() { call Leds.led0Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }
  void report_received() { call Leds.led2Toggle(); }


  event void Boot.booted() {
    cf = 1;
    if (call RadioControl.start() != SUCCESS)
      report_problem();
  }


 event bool RssiMsgIntercept.forward(message_t *msg,
				      void *payload, 
				      uint8_t len) {
    npacket_t *omsg = payload;
    omsg->rssi = getRssi(msg);
//for (i = 0; i < 2; i++){
   if (clientC[i].id != omsg->id){
    clientC[i].id = omsg->id;
    clientC[i].dist = omsg->rssi;
  clientB[i].starC1 = omsg->starC1;
  clientC[i].masterID = TOS_NODE_ID;
  clientC[i].receiveRequest = FALSE;
  clientC[i].facility = FALSE;
      clientU[i] = clientC[i];
  clientB[i]= clientC[i]; 
    printf("The node: = %d\n",rssiMsg->id is connected to : = %d\n",rssiMsg->masterID); // used to find the values
    printfflush();
//}
} 
    return TRUE;
  }

#ifdef __CC2420_H__  
  uint16_t getRssi(message_t *msg){
    return (uint16_t) call CC2420Packet.getRssi(msg);
  }
#elif defined(CC1K_RADIO_MSG_H)
    uint16_t getRssi(message_t *msg){
    cc1000_metadata_t *md =(cc1000_metadata_t*) msg->metadata;
    return md->strength_or_preamble;
  }
#elif defined(PLATFORM_IRIS) || defined(PLATFORM_UCMINI)
  uint16_t getRssi(message_t *msg){
    if(call PacketRSSI.isSet(msg))
      return (uint16_t) call PacketRSSI.get(msg);
    else
      return 0xFFFF;
  }
#elif defined(TDA5250_MESSAGE_H)
   uint16_t getRssi(message_t *msg){
       return call Tda5250Packet.getSnr(msg);
   }
#else
  #error Radio chip not supported! This demo currently works only \
         for motes with CC1000, CC2420, RF230, RFA1 or TDA5250 radios.  
#endif

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

for (i = 0; i < 2; i++){
   if ((clientB[i].facility == FALSE)){


 report2 = ((cf + clientB[i].dist) / (i + 1));

   if (report2 <= temp4) {
   temp4 = report2;
   sendC.starC1 = report2;
   sendC.id = clientB[omsg->id - 1].id;
   sendC.dist = clientB[omsg->id - 1].dist;
   sendC.masterID = TOS_NODE_ID;
   sendC.facility = FALSE;
   connectclientB1 = i;
}
    }
      
  if ((sendC.facility == TRUE)){
    cf = 0;
    
 report2 = (((cf + clientB[i].dist) - (clientB[i].starC1 - clientB[i].dist)) / (i + 1));
     if (report2 < clientB[i].starC1) {

   sendC.starC1 = report2;
   sendC.id = clientB[i].id;
   sendC.dist = clientB[i].dist;
   sendC.masterID = TOS_NODE_ID;
  sendC.facility = TRUE;
   connectclientB1++;
   call Leds.led0On();
   startTimer();    
   }
   }
}
    if (omsg->masterID == TOS_NODE_ID && omsg->receiveRequest == TRUE){
	//for (i = 0; i < 2; i++){      
        connectclientB = i;
	if ((connectclientB = connectclientB1)){
        sendC.id = omsg->id;
        sendC.facility = TRUE;
	cf = 0;        
	clientU[omsg->id - 1] = clientU[omsg->id];
	call Leds.led0On();
        startTimer();
        //}
      }
   }
    else if ((omsg->masterID != TOS_NODE_ID && omsg->receiveRequest == TRUE))
      {
       clientU[omsg->id - 1] = clientU[omsg->id];
        startTimer();
//	call Leds.led0On();
      }
    return msg;
    }

  event void Timer.fired() {  
	if (!sendBusy && sizeof sendC <= call AMSend.maxPayloadLength())
	  {
	    memcpy(call AMSend.getPayload(&sendBuf, sizeof(sendC)), &sendC, sizeof sendC);
	    if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof sendC) == SUCCESS)
	      sendBusy = TRUE;
	if (!sendBusy)
	  report_problem();
        } 
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
