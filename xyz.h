//Define GAMPT xyz-API functions, version 2.3, 01.07.2020
//#include <windows.h>
//#include <stdlib.h>
//#include <stdio.h>

bool	__declspec(dllimport) __stdcall xyz_init();
bool	__declspec(dllimport) __stdcall xyz_init_log();
void	__declspec(dllimport) __stdcall xyz_free();
int  __declspec(dllimport) __stdcall open_usb(char* IDstring);
void	__declspec(dllimport) __stdcall close_usb();
bool	__declspec(dllimport) __stdcall is_open();
int  __declspec(dllimport) __stdcall last_error();
int 	__declspec(dllimport) __stdcall errortext(int error,unsigned char* pbytearray);
//------------------------------------------------------------------------------
bool	__declspec(dllimport) __stdcall dllmessage(bool show_info);
void	__declspec(dllimport) __stdcall show_movetest(bool show_window);
void	__declspec(dllimport) __stdcall show_resolution(bool  show_window);
//------------------------------------------------------------------------------
int  __declspec(dllimport) __stdcall move(unsigned char speed, unsigned char axis,int path, int* pmoevedpath);
bool	__declspec(dllimport) __stdcall set_axes_current(unsigned char axis, bool onoff);
void	__declspec(dllimport) __stdcall get_axes_current(int* paxis_array3);
void	__declspec(dllimport) __stdcall set_zero();
void	__declspec(dllimport) __stdcall get_pos(int* ppos_array3);
void	__declspec(dllimport) __stdcall set_pos(int* ppos_array3);
int*	__declspec(dllimport) __stdcall get_posi();	//result: int* ppos_array3 analog get_pos
int     __declspec(dllimport) __stdcall move_to(unsigned char speed, int* ppos_array3);
//01.02.2018----------------------------------------------------------------------
bool	__declspec(dllimport) __stdcall reset();
void	__declspec(dllimport) __stdcall stop_move();
bool	__declspec(dllimport) __stdcall end_moving();
int	__declspec(dllimport) __stdcall move_start(unsigned char speed,unsigned char axis, int path);
int	__declspec(dllimport) __stdcall get_livepos();
//03.04.2018:---------------------------------------------------------------------
unsigned char	__declspec(dllimport) __stdcall get_speedfak();
void	__declspec(dllimport) __stdcall set_speedfak(unsigned char value);
//5.12.2019---------------------------------------------------------------------
int	__declspec(dllimport) __stdcall get_switches(unsigned char axis);
int*	__declspec(dllimport) __stdcall get_definitions(unsigned char axis);//result: int* pvalue_array5
void	__declspec(dllimport) __stdcall set_definitions(unsigned char axis, int* pvalue_array5);
//06.02.2020----------------------------------------------------------------------
int 	__declspec(dllimport) __stdcall mc_version();
bool 	__declspec(dllimport) __stdcall trigger_on(bool onoff);
unsigned char	__declspec(dllimport) __stdcall trigger_stepsize(unsigned char axis, int path);
bool	__declspec(dllimport) __stdcall trigger_sw(int stepnumber);
int 	__declspec(dllimport) __stdcall get_status();

