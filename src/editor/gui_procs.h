/*
 *  The Moonlight RPG engine  (see readme.txt about version info)
 *  By Bjørn Lindeijer
 *
 ************************************************************************************/

#ifndef GUIPROCS_INCLUDED
#define GUIPROCS_INCLUDED

// GUI procs

int d_bjorn_scroll_proc(int msg, DIALOG *d, int c);
int d_bjorn_camera_knop(int msg, DIALOG *d, int c);
int d_bjorn_map_proc(int msg, DIALOG *d, int c);
int d_bjorn_tile_proc(int msg, DIALOG *d, int c);
int d_bjorn_check_grid(int msg, DIALOG *d, int c);
int d_bjorn_color_proc(int msg, DIALOG *d, int c);
int d_bjorn_close_proc(int msg, DIALOG *d, int c);
int d_bjorn_edit_proc(int msg, DIALOG *d, int c);
int d_bjorn_objects_list(int msg, DIALOG *d, int c);
int d_bjorn_tileset_list(int msg, DIALOG *d, int c);
int d_bjorn_tileset(int msg, DIALOG *d, int c);
int d_bjorn_autotext_proc(int msg, DIALOG *d, int c);
int d_bjorn_slider_proc(int msg, DIALOG *d, int c);
int d_bjorn_obs_preset_proc(int msg, DIALOG *d, int c);
int d_bjorn_obs_proc(int msg, DIALOG *d, int c);
int d_bjorn_check_snap(int msg, DIALOG *d, int c);

int update_color(void *dp3, int d2);
void resizemap_change(DIALOG *d);

char *list_tilesets(int index, int *list_size);
char *list_objects(int index, int *list_size);


#endif
