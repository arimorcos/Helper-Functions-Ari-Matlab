struct key {
    int ascii;
    char character;
    bool alt;
    bool ctrl;
    bool shift;
};

bool init_mexKbhit(void);
struct key mexKbhit(void);
void stop_mexKbhit(void);
