#ifndef RTE_RTE_COM_DEMO_FMT_H
#define RTE_RTE_COM_DEMO_FMT_H

// FILTER(F_COM_DEMO)
#define F_COM_DEMO 1U

// MSG1_RESET_CAUSE "Reset cause: 0x%08X"
#define MSG1_RESET_CAUSE 4U
//  "%[31:1]{ |\n    Low-power reset}Y"
//  "%[30:1]{ |\n    Window watchdog reset}Y"
//  "%[29:1]{ |\n    Independent window watchdog reset}Y"
//  "%[28:1]{ |\n    Software reset}Y"
//  "%[27:1]{ |\n    BOR or POR/PDR}Y"
//  "%[26:1]{ |\n    Reset from NRST pin}Y"

// MSG0_IWDG_RELOAD "IWDG reloaded"
#define MSG0_IWDG_RELOAD 6U

// EXT_MSG0_8_PUSHBUTTON_PRESSED "%u times"
#define EXT_MSG0_8_PUSHBUTTON_PRESSED 256U

#endif
