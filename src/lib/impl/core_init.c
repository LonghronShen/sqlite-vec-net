#include <sqlite-vec.h>
#include <sqlite3.h>

int core_init(const char *dummy) {
  return sqlite3_auto_extension((void *)sqlite3_vec_init);
}

int sqlite3_vecex_init(sqlite3 *db, char **pzErrMsg,
                       const sqlite3_api_routines *pApi) {
  return sqlite3_vec_init(db, pzErrMsg, pApi);
}
