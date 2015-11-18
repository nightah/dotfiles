# This is a modification of Roman Zimbelmann's default colorscheme.
# This software is distributed under the terms of the GNU GPL version 3.

from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import *

class Barrage(ColorScheme):
    progress_bar_color = 234

    def use(self, context):
        fg, bg, attr = default_colors
        if context.reset:
            return default_colors

        elif context.in_browser:
            fg = 244
            if context.selected:
                attr = reverse
            else:
                attr = normal
            if context.empty or context.error:
                fg = 95
                bg = 233
            if context.border:
                fg = 0
            if context.media:
                if context.image:
                    fg = 1
                else:
                    fg = 4
            if context.container:
                fg = 3
            if context.directory:
                fg = 238
            elif context.executable and not \
                    any((context.media, context.container,
                        context.fifo, context.socket)):
                fg = 94
                attr |= bold
            if context.socket:
                fg = 136
                bg = 230
                attr |= bold
            if context.fifo:
                fg = 136
                bg = 230
                attr |= bold
            if context.device:
                fg = 244
                bg = 236
                attr |= bold
            if context.link:
                fg = context.good and 37 or 160
                attr |= bold
                if context.bad:
                    bg = 233
            if context.tag_marker and not context.selected:
                attr |= bold
                if fg in (red, magenta):
                    fg = white
                else:
                    fg = red
            if not context.selected and (context.cut or context.copied):
                fg = 234
                attr |= bold
            if context.main_column:
                if context.selected:
                    attr |= bold
                if context.marked:
                    attr |= bold
                    bg = 236
            if context.badinfo:
                if attr & reverse:
                    bg = 124
                else:
                    fg = 124

        elif context.in_titlebar:
            attr |= bold
            if context.hostname:
                fg = context.bad and 16 or 3
                if context.bad:
                    bg = 166
            elif context.directory:
                fg = 1
            elif context.tab:
                fg = context.good and 1 or 205
                bg = 238
            elif context.link:
                fg = 27

        elif context.in_statusbar:
            if context.permissions:
                if context.good:
                    fg = 1
                elif context.bad:
                    fg = 202
                    bg = 236
            if context.marked:
                attr |= bold | reverse
                fg = 237
                bg = 47
            if context.message:
                if context.bad:
                    attr |= bold
                    fg = 160
                    bg = 235
            if context.loaded:
                bg = self.progress_bar_color

        if context.text:
            if context.highlight:
                attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = 36

            if context.selected:
                attr |= reverse

            if context.loaded:
                if context.selected:
                    fg = self.progress_bar_color
                else:
                    bg = self.progress_bar_color

        return fg, bg, attr
