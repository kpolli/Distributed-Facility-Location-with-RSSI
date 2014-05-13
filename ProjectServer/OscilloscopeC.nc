/*
 * Copyright (c) 2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

/**
 * Oscilloscope demo application. See README.txt file in this directory.
 *
 * @author David Gay
 */

#include "Timer.h"
#include "ServerDist.h"

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
    interface Random;
  }
}
implementation
{
  message_t sendBuf;
  bool sendBusy;
  nx_uint16_t sum;
  nx_uint16_t connectclientB = 0;
  nx_uint16_t connectclientB1 = 0;
  
  //set U = C
  npacket_t clientC[6];
  npacket_t *clientU = (npacket_t*)malloc(size*sizeof(npacket_t));


  // Use LEDs to report various status issues.
  void report_problem() { call Leds.led0Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }
  void report_received() { call Leds.led2Toggle(); }

  event void Boot.booted() {
  clientC[0].id = 1;
  clientC[0].dist = 5;
  clientC[1].id = 2;
  clientC[1].dist = 7;
  clientC[2].id = 3;
  clientC[2].dist = 9;
  clientC[3].id = 4;
  clientC[3].dist = 10;
  clientC[4].id = 5;
  clientC[4].dist = 12;
  clientC[5].id = 6;
  clientC[5].dist = 14;
  clientC[].masterID = TOS_NODE_ID;

  clientC[6] = clientU[6];

    if (call RadioControl.start() != SUCCESS)
      report_problem();
  }

  event void star(){
   nx_uint16_t starC[6];
   nx_uint16_t starD[6];
   npacket_t *sendC = (npacket_t*)malloc(size*sizeof(npacket_t));
   //nx_uint16_t sendC[6];
   for (nx_uint16_t i = 0; i < 6; i++){
   starC[i] = cf + clientU[i].dist - (omsg->clientU[i].dist - clientU[i].dist);
   if (starC[i] <= starD[i])
   {
   sendC[i] = clientU[i];
   starC[i] = starD[i];
   connectclientB1 = connectclientB1 + 1;
   
   }
   else if (starC[i] > starD[i])
    {
     i = 6;
     }
  }
  

  void startTimer() {
    call Timer.startPeriodic(500);
    reading = 0;
  }

  event void RadioControl.startDone(error_t error) {
    startTimer();
  }

  event void RadioControl.stopDone(error_t error) {
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t cf) {
    npacket_t *omsg = payload;

    report_received();
    bool report1 = omsg->receiveRequest;
    /* If we receive a newer version, update our interval. 
       If we hear from a future count, jump ahead but suppress our own change
    */
    if (omsg->masterID = TOS_NODE_ID && report1 = true)
      {
       	connectclientB = connectclientB + 1;
        //call Leds.led0On();
	//startTimer();

        for (nx_uint16_t i = 0; i < connectclientB1; i++){
        if (connectclientB = connectclientB1)
        {
        clientU[i].facility = true;
	call Leds.led0On();
        clientU[i] = clientU[i+1};
        cf = 0;
        }
      }
    }
    else if (omsg->masterID != TOS_NODE_ID && report1 = true)
      {
                  for (nx_uint16_t i = 0; i < connectclientB1; i++){
        if (connectclientB = connectclientB1)
        {
        clientU[i] = clientU[i+1};
        }
      }
      }


    return msg, cf;

  }

  /* At each sample period:
     - if local sample buffer is full, send accumulated samples
     - read next sample
  */
  event void Timer.fired() {
    //if (reading == NREADINGS)
      
	if (!sendBusy && sizeof local <= call AMSend.maxPayloadLength())
	  {
	    // Don't need to check for null because we've already checked length
	    // above
	    memcpy(call AMSend.getPayload(&sendBuf, sizeof(sendC[])), &sendC[], sizeof local);
	    if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof sendC[]) == SUCCESS)
	      sendBusy = TRUE;
	  }
	if (!sendBusy)
	  report_problem();

	reading = 0;
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
