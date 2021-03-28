#include "timestamper.h"

#include "randvardistribution/src/distribution.h"

#include <time.h>
#include <stdlib.h>

static int initilized = 0;

void track(struct ptp_message *msg)
{
    if (initilized == 0)
    {
        srand(time(NULL));

        initilized = 1;
    }

    struct Timestamp* addr;

	uint16_t seconds_msb = 0;
	uint32_t seconds_lsb = 0;
    uint32_t nanoseconds = 0;

    int canmemcopy = 1;

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
		canmemcopy = 0;
	}

	//seconds_msb = ntohl(addr->seconds_msb);

    if (canmemcopy == 1)
    {
        seconds_lsb = ntohl(addr->seconds_lsb); // use
        nanoseconds = ntohl(addr->nanoseconds);
    
        seconds_lsb += 0;
        nanoseconds += (rand() / RAND_MAX) * (300 - 0);

        addr->seconds_lsb = htonl(seconds_lsb);
        addr->nanoseconds = htonl(nanoseconds);
    }
    
	pr_notice("TRANSPORT PEER: msb %lu lsb %lu", seconds_msb, seconds_lsb);
}