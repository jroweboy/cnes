
#ifndef CNES_MACROS_H
#define CNES_MACROS_H

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __NES__

#define _CNES_STRINGIFY(a) #a

#define _CNES_ZP_1(a)    _Pragma (_CNES_STRINGIFY(zpsym ( ## #a ## );));
#define _CNES_ZP_2(a,b)  _CNES_ZP_1(a) _CNES_ZP_1(b)

#define _CNES_ZP_3(a,...)  _CNES_ZP_1(a) _CNES_ZP_2(__VA_ARGS__)
#define _CNES_ZP_4(a,...)  _CNES_ZP_1(a) _CNES_ZP_3(__VA_ARGS__)
#define _CNES_ZP_5(a,...)  _CNES_ZP_1(a) _CNES_ZP_4(__VA_ARGS__)
#define _CNES_ZP_6(a,...)  _CNES_ZP_1(a) _CNES_ZP_5(__VA_ARGS__)
#define _CNES_ZP_7(a,...)  _CNES_ZP_1(a) _CNES_ZP_6(__VA_ARGS__)
#define _CNES_ZP_8(a,...)  _CNES_ZP_1(a) _CNES_ZP_7(__VA_ARGS__)
#define _CNES_ZP_9(a,...)  _CNES_ZP_1(a) _CNES_ZP_8(__VA_ARGS__)
#define _CNES_ZP_10(a,...) _CNES_ZP_1(a) _CNES_ZP_9(__VA_ARGS__)
#define _CNES_ZP_11(a,...) _CNES_ZP_1(a) _CNES_ZP_10(__VA_ARGS__)
#define _CNES_ZP_12(a,...) _CNES_ZP_1(a) _CNES_ZP_11(__VA_ARGS__)
#define _CNES_ZP_13(a,...) _CNES_ZP_1(a) _CNES_ZP_12(__VA_ARGS__)
#define _CNES_ZP_14(a,...) _CNES_ZP_1(a) _CNES_ZP_13(__VA_ARGS__)
#define _CNES_ZP_15(a,...) _CNES_ZP_1(a) _CNES_ZP_14(__VA_ARGS__)
#define _CNES_ZP_16(a,...) _CNES_ZP_1(a) _CNES_ZP_15(__VA_ARGS__)

// NUM_ARGS(...) evaluates to the literal number of the passed-in arguments.
#define _CNES_NUM_ARGS2(X,X16,X15,X14,X13,X12,X11,X10,X9,X8,X7,X6,X5,X4,X3,X2,X1,N,...) N
#define _CNES_NUM_ARGS(...) _CNES_NUM_ARGS2(0, __VA_ARGS__ ,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0)

#define _CNES_ZP_COUNT_PASS2(N, ...) _CNES_ZP_ ## N(__VA_ARGS__)
#define _CNES_ZP_COUNT_PASS1(N, ...) _CNES_ZP_COUNT_PASS2(N, __VA_ARGS__)

/**
 * @brief Define up to 16 symbols as a Zeropage variable
 * 
 * Example:
 * ZP(frame_count, game_state);
 */
#define ZP(...) _CNES_ZP_COUNT_PASS1(_CNES_NUM_ARGS(__VA_ARGS__), __VA_ARGS__)

#else

#define ZP(a) 

#endif // __NES__

#ifdef __cplusplus
}
#endif

#endif // CNES_MACROS_H