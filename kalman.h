#pragma once

#include <stdlib.h>
#include <string.h>

#ifndef HAVE_KALMAN_H
#define HAVE_KALMAN_H

#include "print.h"
#include "filter_private.h"

struct filter *kalman_create();

#endif