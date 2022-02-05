
#ifndef CNES_STATE_H
#define CNES_STATE_H

#ifdef __cplusplus
extern "C" {
#endif

#include "common_types.h"
#include "cnes_macros.h"

typedef void(*cnes_fast_func)(void);

#ifdef __NES__

#define FAST_FUNC(func) \
  _Pragma("bss-name(push, \"ZEROPAGE\", \"zp\");"); \
  static volatile u8 func[3]; \
  _Pragma("bss-name(pop);");

#define FAST_FUNC_INIT(func) func[0] = 0x4c;

#define FAST_FUNC_SET(func, newfunc) \
  __asm__("lda #.lobyte(%v)", newfunc); \
  __asm__("sta %v + 1", func); \
  __asm__("lda #.hibyte(%v)", newfunc); \
  __asm__("sta %v + 2", func);

#define FAST_CALL(func) __asm__("jsr %v", func);

#else

#define FAST_FUNC(name) static cnes_fast_func name;
#define FAST_FUNC_SET(name, newfunc) do { name = newfunc; } while (0);
#define FAST_CALL(name) name();
#define FAST_FUNC_INIT(name)

#endif // __NES__

#ifdef __cplusplus
}
#endif

#endif //CNES_STATE_H
