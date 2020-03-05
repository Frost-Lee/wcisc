#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "model.h"

// - MARK: Attributes
ModelState modelState = Not_Initialized;
AutoInfusionConfiguration autoInfusionConfiguration;
InfusionSafetyConfiguration infusionSafetyConfiguration;
ControllerDelegate controllerDelegate;

/**
 * Initialize the model by setting the delegates.
 *
 * @param infuse Infuse the drug when this method is called.
 * @param send Send the arguments to central device when this method is called. Remember to `free` the argument.
 * @param stop Stop the current running infusion when this method is called.
 */
void initialize(void (*infuse)(float), void(*send)(char*), void (*stop)()) {
    controllerDelegate.infuse = infuse;
    controllerDelegate.send = send;
    controllerDelegate.stop = stop;
    modelState = Not_Configured;
}

/**
 * Pass the input from central device to the model. The input may trigger state changes
 * or other delegate methods.
 *
 * @param input The original input from the central device. See README.md for this repo for details.
 */
void execute(const char* input) {
    if (modelState == Not_Initialized) {return;}
    float arguments[5] = {};
    stringToFloats(input + 2, arguments, ';');
    switch (input[0]) {
        case 'c':
            handleAutoInfusionConfigure(arguments[0], arguments[1]);
            break;
        case 'a':
            handleAutoInfusion();
            break;
        case 'i':
            handleInfusion(arguments[0]);
            break;
        case 's':
            handleStop();
            break;
        default:
            break;
    }
}

/**
 * Notify the model that some operation has been finished.
 * The status code explanations are given as follows.
 *
 * 0: successfully infused
 * 1: external device not aligned during infusion
 * 2: infusion cannot be triggered
 * 3: pump needs refilling
 *
 * @param status The status code.
 * @param dosage The dosage that was expected to inject.
 */
void notify(short status, float dosage) {
    if (modelState == Not_Initialized) {return;}
    char* responseString = (char*)malloc(sizeof(char) * 20);
    /* FIXME: The infusion may be triggered by auto-infusion or manual-infusion, thus `modelState` should be returned to `Configured` or `Not_Configured`. */
    modelState = Configured;
    /* FIXME: Due to the minimum version of C standard library that Arduion adopts, `sprintf` cannot format float here. */
    sprintf(responseString, "l:%d;%d", (int)dosage, status);
    (*controllerDelegate.send)(responseString);
}

/**
 * Reset the model's state.
 */
void reset() {
    modelState = Not_Initialized;
}

void handleAutoInfusionConfigure(float timeInterval, float dosage) {
    autoInfusionConfiguration.timeInterval = timeInterval;
    autoInfusionConfiguration.dosage = dosage;
    modelState = Configured;
}

void handleAutoInfusion() {
    if (modelState != Configured) {return;}
    modelState = Infusing;
    (*controllerDelegate.infuse)(autoInfusionConfiguration.dosage);
}

void handleInfusion(float dosage) {
    if (modelState == Not_Initialized || modelState == Infusing) {return;}
    modelState = Infusing;
    (*controllerDelegate.infuse)(dosage);
}

void handleStop() {
    (*controllerDelegate.stop)();
}

void stringToFloats(const char* string, float* container, char separator) {
    float result = 0;
    int index = 0, resultIndex = 0;
    bool isDecimal = False;
    int decimalLength = 0;
    while (index < strlen(string)) {
        char currentChar = string[index];
        if (!((currentChar >= '0' && currentChar <= '9') || currentChar == separator || currentChar == '.')) {return;}
        if (currentChar == separator) {
            container[resultIndex ++] = result;
            result = 0;
            isDecimal = False;
            decimalLength = 0;
        } else if (currentChar == '.') {
            if (isDecimal) {return;}
            isDecimal = True;
        } else {
            float value = (float)(currentChar - '0');
            if (isDecimal) {
                decimalLength += 1;
                for (int i = 0; i < decimalLength; i ++) {
                    value /= 10;
                }
                result += value;
            } else {
                result *= 10;
                result += value;
            }
        }
        index ++;
    }
    container[resultIndex] = result;
}
