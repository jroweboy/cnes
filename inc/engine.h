
#ifndef CNES_ENGINE_H
#define CNES_ENGINE_H

#include "common_types.h"

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

extern void (*driver_nmi)(void);
extern void (*driver_reset)(void);
extern void (*driver_irq)(void);

#endif //CNES_ENGINE_H
