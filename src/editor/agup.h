/*
 * This file is part of the Allegro GUI Un-uglification Project.
 */

#ifndef _agup_included_agup_h
#define _agup_included_agup_h

struct agup_theme;

extern int agup_fg_color;
extern int agup_bg_color;

void agup_init(AL_CONST struct agup_theme *);
void agup_shutdown(void);

int d_agup_box_proc(int, DIALOG *, int);
int d_agup_shadow_box_proc(int, DIALOG *, int);
int d_agup_button_proc(int, DIALOG *, int);
int d_agup_push_proc(int, DIALOG *, int);
int d_agup_check_proc(int, DIALOG *, int);
int d_agup_radio_proc(int, DIALOG *, int);
int d_agup_icon_proc(int, DIALOG *, int);
int d_agup_edit_proc(int, DIALOG *, int);
int d_agup_list_proc(int, DIALOG *, int);
int d_agup_text_list_proc(int, DIALOG *, int);
int d_agup_textbox_proc(int, DIALOG *, int);
int d_agup_slider_proc(int, DIALOG *, int);
int d_agup_menu_proc(int, DIALOG *, int);
int d_agup_window_proc(int, DIALOG *, int);

#endif
