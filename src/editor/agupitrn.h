/*
 * This file is part of the Allegro GUI Un-uglification Project.
 */

#ifndef _agup_included_agupitrn_h
#define _agup_included_agupitrn_h

struct agup_theme {
    int *fg_color;
    int *bg_color;
    void (*init)(void);
    void (*shutdown)(void);
    int (*box_proc)(int, DIALOG *, int);
    int (*shadow_box_proc)(int, DIALOG *, int);
    int (*button_proc)(int, DIALOG *, int);
    int (*push_proc)(int, DIALOG *, int);
    int (*check_proc)(int, DIALOG *, int);
    int (*radio_proc)(int, DIALOG *, int);
    int (*icon_proc)(int, DIALOG *, int);
    int (*edit_proc)(int, DIALOG *, int);
    int (*list_proc)(int, DIALOG *, int);
    int (*text_list_proc)(int, DIALOG *, int);
    int (*textbox_proc)(int, DIALOG *, int);
    int (*slider_proc)(int, DIALOG *, int);
    int (*menu_proc)(int, DIALOG *, int);
    int (*window_proc)(int, DIALOG *, int);
};

/* internal Allegro function, don't want aintern.h just for this */
#ifdef __cplusplus
extern "C"
#endif
void _draw_textbox(char *, int *, int, int, int, int, int, int, int, int, int, int, int, int);

#endif
