/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of GNOMECAT
 *
 * Copyright (C) 2014 - Marcos Chavarría Teijeiro
 *
 * GNOMECAT is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * GNOMECAT is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with GNOMECAT. If not, see <http://www.gnu.org/licenses/>.
 */

namespace GNOMECAT.UI
{


    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/welcomepanel.ui")]
    public class WelcomePanel : Gtk.Box, Panel
    {

        private GNOMECAT.UI.FirstProfilePanel fstprofilepanel;

        public GNOMECAT.UI.ToolBarMode toolbarmode
        {
            get
            {
                return GNOMECAT.UI.ToolBarMode.COMPLETE;
            }
        }

        public int window_page {get; set;}

        public GNOMECAT.UI.Window window
        {
            get
            {
                return get_parent ().get_parent ().get_parent () as GNOMECAT.UI.Window;
            }
        }

        public WelcomePanel ()
        {
            fstprofilepanel = new GNOMECAT.UI.FirstProfilePanel();
        }

        [GtkCallback]
        private void on_create_profile (Gtk.Widget w)
        {
            window.set_panel(WindowStatus.OTHER, fstprofilepanel);
            window.window_panels.remove_page (window_page);
        }

        public void setup_headerbar (GNOMECAT.UI.ToolBar toolbar)
        {
            toolbar.mode = toolbarmode;
            toolbar.stack_switch.visible = false;
            toolbar.done_btn.visible = false;
            toolbar.back_btn.visible = false;
        }
    }
}


