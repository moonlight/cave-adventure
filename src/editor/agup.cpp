/* agup.c
 * 
 * This file is part of the Allegro GUI Un-uglification Project.
 * It provides "theming" ability.
 *
 * Peter Wang <tjaden@users.sourceforge.net>
 */


#include <allegro.h>
#include "agup.h"
#include "agupitrn.h"


static AL_CONST struct agup_theme *theme;


int agup_fg_color;
int agup_bg_color;


void agup_init(AL_CONST struct agup_theme *thm)
{
    if ((theme = thm)) {
        theme->init();
        agup_fg_color = *(theme->fg_color);
        agup_bg_color = *(theme->bg_color);
    }
}


void agup_shutdown(void)
{
    if (theme) {
        theme->shutdown();
        theme = NULL;
    }
}


#define MAKE_WRAPPER(wrapper, proc)                                     \
    int wrapper(int msg, DIALOG *d, int c)                              \
{                                                                       \
    return ((theme) && (theme->proc)) ? theme->proc(msg, d, c) : D_O_K; \
}

MAKE_WRAPPER(d_agup_box_proc, box_proc);
MAKE_WRAPPER(d_agup_shadow_box_proc, shadow_box_proc);
MAKE_WRAPPER(d_agup_button_proc, button_proc);
MAKE_WRAPPER(d_agup_push_proc, push_proc);
MAKE_WRAPPER(d_agup_check_proc, check_proc);
MAKE_WRAPPER(d_agup_radio_proc, radio_proc);
MAKE_WRAPPER(d_agup_icon_proc, icon_proc);
MAKE_WRAPPER(d_agup_edit_proc, edit_proc);
MAKE_WRAPPER(d_agup_list_proc, list_proc);
MAKE_WRAPPER(d_agup_text_list_proc, text_list_proc);
MAKE_WRAPPER(d_agup_textbox_proc, textbox_proc);
MAKE_WRAPPER(d_agup_slider_proc, slider_proc);
MAKE_WRAPPER(d_agup_menu_proc, menu_proc);
MAKE_WRAPPER(d_agup_window_proc, window_proc);
