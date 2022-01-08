
#ifndef CNES_ENGINE_H
#define CNES_ENGINE_H

#include "common_types.h"

/**
 * @brief 
 * 
 */
void __LIB_CALLSPEC wait_for_frame_end();

/**
 * @brief User provided IRQ callback
 * 
 */
extern void irq_callback();

/**
 * @brief User provided NMI callback
 * 
 */
extern void nmi_callback();

#endif //CNES_ENGINE_H
