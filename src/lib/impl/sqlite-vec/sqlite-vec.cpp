#ifndef A14E8144_47F5_4939_89B8_00BFA5580B09
#define A14E8144_47F5_4939_89B8_00BFA5580B09

extern "C" {
#include <sqlite-vec.h>
#include <sqlite3.h>

#include <sqlite-vec.h>
}

namespace sqlite {
namespace extensions {
namespace vec0 {
int sqlite3_vec_init(void) {
  return sqlite3_auto_extension((void (*)())::sqlite3_vec_init);
}
} // namespace vec0
} // namespace extensions
} // namespace sqlite

#endif /* A14E8144_47F5_4939_89B8_00BFA5580B09 */
