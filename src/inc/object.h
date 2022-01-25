
#ifndef CNES_OBJECT_H
#define CNES_OBJECT_H

#ifdef __cplusplus
extern "C" {
#endif

#include "common_types.h"
#include <stddef.h>

#ifdef __NES__

/**
 * @brief Maximum number of dynamic object slots available
 */
#define CNES_MAX_OBJECTS 32
/**
 * @brief Maximum number of attributes an object can have
 * 
 */
#define CNES_MAX_ATTR 24

/**
 * @brief Either a user provided load function, or one of the preconfigured load functions provided
 * by CNES. These load functions are unrolled so choose the right one for however many attributes your
 * objects will have.
 */
extern void(void*) cnes_object_loader;

/**
 * @brief User allocated memory for the object array.
 */
extern const u8* cnes_object_data;

void __LIB_CALLSPEC spawn_object(u8 object_id, u8 object_slot);

#ifndef OBJ_TYPE
#define OBJ_TYPE struct object
#endif //OBJ_TYPE

#ifndef NUM_OBJ
#define NUM_OBJ 32
#endif

#define NUM_ATTR sizeof(OBJ_TYPE)
#define ATTR_PTR(attr) (cnes_object_data + (offsetof(OBJ_TYPE, attr) * NUM_OBJ))

#define OBJ(loc, attr) (ATTR_PTR(attr) + loc)

#include "object_p.h"

#else

#endif

#ifdef __cplusplus
}
#endif

#endif // CNES_OBJECT_H