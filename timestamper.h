#pragma once

#include "print.h"
#include "msg.h"


void track(struct ptp_message *msg)
{
    struct Timestamp* addr;

	uint16_t seconds_msb = 0;
	uint32_t seconds_lsb = 0;

    bool canmemcopy = true;

	switch (msg->header.tsmt)
	{
	case SYNC:
		addr = &msg->sync.originTimestamp; // 6 bytes for secs
		break;
	case DELAY_REQ:
		addr = &msg->delay_req.originTimestamp;
		break;
	case PDELAY_REQ:
		addr = &msg->pdelay_req.originTimestamp;
		break;
	case PDELAY_RESP:
		addr = &msg->pdelay_resp.requestReceiptTimestamp;
		break;
	case FOLLOW_UP:
		addr = &msg->follow_up.preciseOriginTimestamp;
		break;
	case DELAY_RESP:
		addr = &msg->delay_resp.receiveTimestamp;
		break;
	case PDELAY_RESP_FOLLOW_UP:
		addr = &msg->pdelay_resp_fup.responseOriginTimestamp;
		break;
	case ANNOUNCE:
		addr = &msg->announce.originTimestamp;
		break;

		default:
		canmemcopy = false;
	}

	//seconds_msb = ntohl(addr->seconds_msb);

    if (canmemcopy)
    {
        seconds_lsb = ntohl(addr->seconds_lsb); // use
    
        seconds_lsb += 600;

        addr->seconds_lsb = htonl(seconds_lsb);
    }
    
	pr_notice("TRANSPORT PEER: msb %lu lsb %lu", seconds_msb, seconds_lsb);
}