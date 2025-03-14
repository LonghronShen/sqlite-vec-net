#include <stdio.h>

#include "sqlite-vec.h"
#include "sqlite3.h"

int core_init(const char *dummy) {
  return sqlite3_auto_extension((void *)sqlite3_vec_init);
}