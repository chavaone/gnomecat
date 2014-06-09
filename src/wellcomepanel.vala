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


    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/wellcomepanel.ui")]
    public class WellcomePanel : Gtk.Box, Panel
    {

    	public GNOMECAT.UI.ToolBarMode toolbarmode
        {
            get
            {
                return GNOMECAT.UI.ToolBarMode.EMPTY;
            }
        }

        public int window_page {get; set;}

        public GNOMECAT.UI.Window window
        {
            get
            {
                return this.get_parent().get_parent() as GNOMECAT.UI.Window;
            }
        }

        [GtkCallback]
        private void on_create_profile (Gtk.Widget w)
        {
            window.set_panel(WindowStatus.OTHER, new GNOMECAT.UI.FirstProfilePanel());
            window.window_panels.remove_page (window_page);
        }
    }
}


