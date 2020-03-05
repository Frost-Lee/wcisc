#ifndef MODEL_H
#define MODEL_H

// - MARK: Type definitions
typedef enum {
    False,
    True
} bool;

typedef enum {
    Not_Initialized,
    Not_Configured,
    Configured,
    Infusing
} ModelState;

typedef struct {
    float timeInterval;
    float dosage;
    // Should also be start time here
} AutoInfusionConfiguration;

typedef struct {
    float maxDailyDosage;
} InfusionSafetyConfiguration;

typedef struct {
    void (*infuse)(float);
    void (*send)(char*);
    void (*stop)();
} ControllerDelegate;

// - MARK: Public methods
void initialize(void (*infuse)(float), void(*send)(char*), void (*stop)());
void execute(const char* input);
void notify(short status, float dosage);
void reset();

// - MARK: Private methods
void handleAutoInfusionConfigure(float timeInterval, float dosage);
void handleAutoInfusion();
void handleInfusion(float dosage);
void handleStop();

void stringToFloats(const char* string, float* container, char separator);

#endif
