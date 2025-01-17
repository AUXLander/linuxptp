#include "timestamper.h"

#include <time.h>
#include <stdlib.h>

extern int noiseEnable;
extern enum noise_type noise;

extern uint64_t uniform_next();
extern uint64_t poisson_next();
extern uint64_t  normal_next();

void track(struct ptp_message *msg)
{
	if (noiseEnable == 1)
	{
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
		

			switch(noise)
			{
				case uniform_noise:
				{
					seconds_lsb += 0;
					nanoseconds += uniform_next();
				}; 
				break;
				
				case poisson_noise:
				{
					seconds_lsb += 0;
					nanoseconds += poisson_next();
				}; 
				break;
				
				case normal_noise:
				{
					seconds_lsb += 0;
					nanoseconds += normal_next();
				}; 
				break;

				default:
				break;
			}
			

			addr->seconds_lsb = htonl(seconds_lsb);
			addr->nanoseconds = htonl(nanoseconds);
		}
		
		// pr_notice("uniform: %ld", uniform_next());
		// pr_notice("poisson: %ld", poisson_next());
		// pr_notice(" normal: %ld",  normal_next());

		// pr_notice("TRANSPORT PEER: msb %lu lsb %lu", seconds_msb, seconds_lsb);
	}
}