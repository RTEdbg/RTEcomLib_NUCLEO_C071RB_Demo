#ifndef RTE_CORTEX_M0_FAULT_FMT_H
#define RTE_CORTEX_M0_FAULT_FMT_H

/* cortex_M0_fault_fmt.h */

// IN_FILE(EXC_NAMES, "cortex_M0_exceptions.txt")

// MSGN_FATAL_EXCEPTION
#define MSGN_FATAL_EXCEPTION 16U
// "\nCPU registers"
// "\n  R00:0x%[320:32u]08X, R01:0x%08X, R02:0x%08X, R03:0x%08X"
// "\n  R04:0x%[192:32u]08X, R05:0x%08X, R06:0x%08X, R07:0x%08X"
// "\n  R08:0x%[64:32u]08X, R09:0x%08X, R10:0x%08X, R11:0x%08X"
// "\n  R12:0x%[448:32u]08X,  SP:0x%[32:32u](+64)08X,  LR:0x%[480:32u]08X,  PC:0x%[512:32u]08X"
// "\n  xPSR:0x%[544:32u]08X, Flags: V=%[-4:1]u, C=%[1]u, Z=%[1]u, N=%[1]u"
// <EXC_NAMES "\n     Interrupted exception: #%[-32:6u]d - %[-6:6]Y (vector table address: 0x%[-6:6u](*4)02X)"
// "\n  ICSR: 0x%[0:32u]08X"
// <EXC_NAMES "\n     Active exception: #%[-32:9u]u - %[-9:9u]Y (vector table address: 0x%[-9:9u](*4)02X)"
// <EXC_NAMES "\n     Pending exception: #%[+3:9u]u - %[-9:9u]Y (vector table address: 0x%[-9:9u](*4)02X)"
// "%[+1:1u]{ |\n     Interrupt is pending}Y"
// "%[+0:1u]{ |\n     Services a pending exception}Y"
// "%[+2:1u]{ |\n     SysTick exception is pending}Y"
// "%[+1:1u]{ |\n     PendSV exception is pending}Y"
// "%[+2:1u]{ |\n     NMI exception is pending}Y"
/* Delete the last string of format definition (starting with "%[544:32u]) in case no stack dump will be logged. */
/* Note: The "%[544:32u]{ | }Y" is a dummy print to set the address from which the stack data begins. */
// "%[544:32u]{ | }Y\nStack dump (hex)%4H"

#endif
