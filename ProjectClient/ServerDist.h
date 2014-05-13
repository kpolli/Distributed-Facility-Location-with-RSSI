/*
 * Copyright (c) 2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

// @author David Gay

#ifndef SERVERDIST_H
#define SERVERDIST_H


enum {
  /* Number of readings per message. If you increase this, you may have to
     increase the message_t size. */
  NREADINGS = 10,

  /* Default sampling period. */
  DEFAULT_INTERVAL = 256,
  sum = 2,
  sum1 = 1,
  sum2 = 10,
  sum3 = 7,
  AM_SERVERDIST = 0x99,
  AM_RSSIMSG = 10
};
// set C


typedef nx_struct npacket {
  nx_uint16_t rssi;
  nx_uint16_t id; /* Version of the interval. */
  nx_uint16_t dist; /* Distance to server. */
  nx_bool receiveRequest; /* Connection request */
  nx_bool facility; /* Facility open */
  nx_uint16_t masterID; /* Server ID */
  nx_uint16_t starC1; /* Star co-efficient*/

} npacket_t;

#endif
