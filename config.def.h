/* See LICENSE file for copyright and license details. */

/* Include generated theme colors — built by dwm-generate-theme from colors.toml */
#include "themes/current/colors.h"
#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx  = 3;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int swallowfloating    = 0;        /* 1 means swallow floating windows by default */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const int usealtbar          = 1;        /* 1 means use non-dwm status bar */
static const char *altbarclass      = "Polybar"; /* Alternate bar class name */
static const char *altbarcmd        = ""; /* Alternate bar launch command */
static const char dmenufont[]       = "monospace:size=10";
static const char *fonts[]          = { "monospace:size=10" };
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_normfg, col_normbg, col_normborder },
	[SchemeSel]  = { col_selfg,  col_selbg,  col_selborder  },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 *
	 * Geometry/position (MangoWM-style, only for floating windows):
	 *	rulew/ruleh  = 0 unset · <1 fraction of monitor · >=1 pixels
	 *	offsetx/offsety = % offset from center (0 = centered, 100 = edge,
	 *	                  negative = left/up); 100 gives edge-aligned PiP
	 *	no_force_center = 1 keeps window's own position instead of centering
	 *	isoverlay       = 1 keep window raised above tiled windows
	 *	isopensilent    = 1 open without stealing focus
	 *	isnosizehint    = 1 ignore client min/max/aspect size hints
	 *	isglobal        = 1 sticky on all tags (never shown in occupied tags)
	 */
	/* class                  instance  title                      tags mask  isfloating  isterminal  noswallow  monitor  rulew   ruleh   offx  offy  nfc  ovly  silent  noszh  globl */
	{ "Gimp",                 NULL,     NULL,                      0,         1,          0,           0,        -1,       0,     0,     0,    0,    0,   0,    0,      0,     0 },
	{ "steam",                NULL,     NULL,                      1 << 8,    1,          0,          -1,        -1,       0,     0,     0,    0,    0,   0,    0,      0,     0 },
	{ "Localse",              NULL,     NULL,                      0,         1,          0,          -1,        -1,       0,     0,     0,    0,    0,   0,    0,      0,     0 },
	{ "org.dwm.",             NULL,     NULL,                      0,         1,          1,           0,        -1,       0.6f,  0.7f,  0,    0,    0,   0,    0,      0,     0 },
	{ "org.dwm.browser",      NULL,     NULL,                      1 << 1,    0,          0,          -1,        -1,       0,     0,     0,    0,    0,   0,    0,      0,     0 },
	{ "org.dwm.terminal",     NULL,     NULL,                      0,         0,          1,           0,        -1,       0,     0,     0,    0,    0,   0,    0,      0,     0 },
	{ "dwm-system-update",    NULL,     NULL,                      0,         1,          0,           0,        -1,       0.6f,  0.7f,  0,    0,    0,   0,    0,      0,     0 },
	/* picture-in-picture: 35% of monitor (16:9), top-right, kept above,
	 * opened without focus, ignores size hints, sticky on all tags */
	{ NULL,                   NULL,     "Picture",                ~0,         1,          0,           0,        -1,       0.35f, 0.35f, 96,   -90,  0,   1,    1,      1,     1 },
	{ NULL,                   NULL,     "Event Tester",            0,         0,          0,           1,        -1,       0,     0,     0,    0,    0,   0,    0,      0,     0 }, /* xev */
};

/* layout(s) */
static const float mfact          = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster          = 1;    /* number of clients in master area */
static const int resizehints      = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen   = 1;    /* 1 will force focus on the fullscreen window */
static const int refreshrate      = 120;  /* refresh rate (per second) for client move/resize */

#include "fibonacci.c"
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
	{ "[@]",      spiral },
	{ "[\\]",     dwindle },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[]     = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_normbg, "-nf", col_normfg, "-sb", col_selbg, "-sf", col_selfg, NULL };
static const char *screenshot[]   = { "dwm-launch-menu", "screenshot", NULL};
static const char *screenrecord[] = { "dwm-launch-menu", "screenrecord", NULL};
static const char *rofi_druncmd[] = { "dwm-launch-menu", "drun", NULL };

#include "movestack.c"
static const Key keys[] = {
	/* modifier                     key             function                       argument */
	{ MODKEY,                       XK_q,           killclient,                    {0} },
	{ MODKEY|ShiftMask,             XK_Return,      spawn,                         SHCMD("dwm-launch-terminal") },
	{ MODKEY,                       XK_Return,      spawn,                         SHCMD("dwm-launch-terminal-cwd") },
	{ MODKEY|ShiftMask,             XK_b,           spawn,                         SHCMD("dwm-launch-browser") },
	{ MODKEY,                       XK_space,       spawn,                         {.v = rofi_druncmd } },
	{ MODKEY|Mod1Mask,              XK_space,       spawn,                         SHCMD("dwm-launch-menu") },
  { MODKEY|Mod1Mask,              XK_m,           spawn,                         SHCMD("dwm-launch-music") },
	{ MODKEY,                       XK_b,           togglebar,                     {0} },
	{ MODKEY,                       XK_j,           focusstack,                    {.i = +1 } },
	{ MODKEY,                       XK_k,           focusstack,                    {.i = -1 } },
	{ MODKEY,                       XK_i,           incnmaster,                    {.i = +1 } },
	{ MODKEY,                       XK_d,           incnmaster,                    {.i = -1 } },
	{ MODKEY,                       XK_h,           setmfact,                      {.f = -0.05} },
	{ MODKEY,                       XK_l,           setmfact,                      {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_h,           setcfact,                      {.f = +0.25} },
	{ MODKEY|ShiftMask,             XK_l,           setcfact,                      {.f = -0.25} },
	{ MODKEY|ShiftMask,             XK_o,           setcfact,                      {.f =  0.00} },
	{ MODKEY|ShiftMask,             XK_j,           movestack,                     {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_k,           movestack,                     {.i = -1 } },
	{ MODKEY,                       XK_z,           zoom,                          {0} },
	{ MODKEY,                       XK_Tab,         view,                          {0} },
	{ MODKEY|ShiftMask,             XK_c,           setlayout,                     {0} },
	{ MODKEY,                       XK_t,           togglefloating,                {0} },
	{ MODKEY,                       XK_f,           fullscreen,                    {0} },
	{ MODKEY|ShiftMask,             XK_f,           fakefullscreen,                {0} },
	{ MODKEY,                       XK_0,           view,                          {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,           tag,                           {.ui = ~0 } },
	{ MODKEY,                       XK_comma,       focusmon,                      {.i = -1 } },
	{ MODKEY,                       XK_period,      focusmon,                      {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,       tagmon,                        {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period,      tagmon,                        {.i = +1 } },
	TAGKEYS(                        XK_1,                                          0)
	TAGKEYS(                        XK_2,                                          1)
	TAGKEYS(                        XK_3,                                          2)
	TAGKEYS(                        XK_4,                                          3)
	TAGKEYS(                        XK_5,                                          4)
	TAGKEYS(                        XK_6,                                          5)
	TAGKEYS(                        XK_7,                                          6)
	TAGKEYS(                        XK_8,                                          7)
	TAGKEYS(                        XK_9,                                          8)
	{ 0,                            XK_Print,       spawn,                         {.v = screenshot } },
	{ ShiftMask,                    XK_Print,       spawn,                         {.v = screenrecord } },
	{ MODKEY|ControlMask,           XK_l,           spawn,                         SHCMD("dwm-lock-screen") },
	{ MODKEY|ShiftMask,             XK_q,           quit,                          {0} },

  /* Fn keys - universal XF86 keysyms */
	/* Volume controls */
	{ 0,                            XF86XK_AudioRaiseVolume,          spawn,       SHCMD("dwm-cmd-volume raise") },
	{ 0,                            XF86XK_AudioLowerVolume,          spawn,       SHCMD("dwm-cmd-volume lower") },
	{ 0,                            XF86XK_AudioMute,                 spawn,       SHCMD("dwm-cmd-volume mute-toggle") },
	{ 0,                            XF86XK_AudioMicMute,              spawn,       SHCMD("pamixer --default-source --toggle-mute") },
	{ Mod1Mask,                     XF86XK_AudioRaiseVolume,          spawn,       SHCMD("dwm-cmd-volume +1") },
	{ Mod1Mask,                     XF86XK_AudioLowerVolume,          spawn,       SHCMD("dwm-cmd-volume -1") },
	{ ShiftMask,                    XF86XK_AudioMute,                 spawn,       SHCMD("dwm-cmd-audio-switch") },
	/* Brightness controls */
	{ 0,                            XF86XK_MonBrightnessUp,           spawn,       SHCMD("dwm-cmd-brightness +5%") },
	{ 0,                            XF86XK_MonBrightnessDown,         spawn,       SHCMD("dwm-cmd-brightness 5%-") },
	{ ShiftMask,                    XF86XK_MonBrightnessUp,           spawn,       SHCMD("dwm-cmd-brightness 100%") },
	{ ShiftMask,                    XF86XK_MonBrightnessDown,         spawn,       SHCMD("dwm-cmd-brightness 1%") },
	{ Mod1Mask,                     XF86XK_MonBrightnessUp,           spawn,       SHCMD("dwm-cmd-brightness +1%") },
	{ Mod1Mask,                     XF86XK_MonBrightnessDown,         spawn,       SHCMD("dwm-cmd-brightness 1%-") },
	/* Keyboard backlight */
	{ 0,                            XF86XK_KbdBrightnessUp,           spawn,       SHCMD("dwm-cmd-kbd-brightness up") },
	{ 0,                            XF86XK_KbdBrightnessDown,         spawn,       SHCMD("dwm-cmd-kbd-brightness down") },
	{ 0,                            XF86XK_KbdLightOnOff,             spawn,       SHCMD("dwm-cmd-kbd-brightness cycle") },
	/* Touchpad */
	{ 0,                            XF86XK_TouchpadToggle,            spawn,       SHCMD("dwm-toggle-touchpad") },
	{ 0,                            XF86XK_TouchpadOn,                spawn,       SHCMD("dwm-toggle-touchpad on") },
	{ 0,                            XF86XK_TouchpadOff,               spawn,       SHCMD("dwm-toggle-touchpad off") },
	/* Media controls */
	{ 0,                            XF86XK_AudioNext,                 spawn,       SHCMD("playerctl next") },
	{ 0,                            XF86XK_AudioPrev,                 spawn,       SHCMD("playerctl previous") },
	{ 0,                            XF86XK_AudioPause,                spawn,       SHCMD("playerctl play-pause") },
	{ 0,                            XF86XK_AudioPlay,                 spawn,       SHCMD("playerctl play-pause") },
	{ 0,                            XF86XK_AudioStop,                 spawn,       SHCMD("playerctl stop") },
	{ 0,                            XF86XK_Eject,                     spawn,       SHCMD("eject") },
	{ Mod1Mask,                     XF86XK_AudioPlay,                 spawn,       SHCMD("playerctl next") },
	{ Mod1Mask|ShiftMask,           XF86XK_AudioPlay,                 spawn,       SHCMD("playerctl previous") },
	{ ShiftMask,                    XF86XK_AudioPause,                spawn,       SHCMD("dwm-cmd-media-source-switch") },
	{ ShiftMask,                    XF86XK_AudioPlay,                 spawn,       SHCMD("dwm-cmd-media-source-switch") },
	/* Network */
	{ 0,                            XF86XK_WLAN,                      spawn,       SHCMD("rfkill toggle wifi") },
	{ 0,                            XF86XK_Bluetooth,                 spawn,       SHCMD("rfkill toggle bluetooth") },
	/* Launchers */
	{ 0,                            XF86XK_Calculator,                spawn,       SHCMD("gnome-calculator") },
	{ 0,                            XF86XK_HomePage,                  spawn,       SHCMD("dwm-launch-browser") },
	{ 0,                            XF86XK_WWW,                       spawn,       SHCMD("dwm-launch-browser") },
	{ 0,                            XF86XK_ScreenSaver,               spawn,       SHCMD("dwm-lock-screen") },
	{ 0,                            XF86XK_Sleep,                     spawn,       SHCMD("systemctl suspend") },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          SHCMD("dwm-launch-terminal") },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

