/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of GNOMECAT
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
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
    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/openfilepanel.ui")]
    public class OpenFilePanel : Gtk.Box, GNOMECAT.UI.Panel
    {

        public GNOMECAT.UI.ToolBarMode toolbarmode
        {
            get
            {
                return GNOMECAT.UI.ToolBarMode.BACK;
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

        public void on_back (GNOMECAT.UI.Window window)
        {
            window.set_panel(WindowStatus.OPENEDFILES);
        }

        [GtkCallback]
        public void on_new_file (Gtk.Button b)
        {
            Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (_("Select a file to open."),
                window, Gtk.FileChooserAction.OPEN,
                _("Cancel"), Gtk.ResponseType.CANCEL,
                _("Open"), Gtk.ResponseType.ACCEPT);

            chooser.filter = new Gtk.FileFilter ();
            var app = GNOMECAT.Application.get_default ();
            foreach (string ext in (app as GNOMECAT.Application).extensions)
            {
                chooser.filter.add_pattern ("*." + ext);
            }

            chooser.select_multiple = false;

            if (chooser.run () == Gtk.ResponseType.ACCEPT)
            {
                do_open_file (chooser.get_file());
            }

            chooser.destroy ();
        }

        [GtkCallback]
        private void on_recent_file_activated (GNOMECAT.FileProject.File file)
        {
            (window.window_panels.get_nth_page (WindowStatus.OPENEDFILES) as OpenedFilesPanel).add_file (file);
            (window.window_panels.get_nth_page (WindowStatus.OPENEDFILES) as OpenedFilesPanel).file_activated (file);
        }

        private void do_open_file (GLib.File f)
        {
            GNOMECAT.FileProject.File? file = GNOMECAT.Application.get_default ()
            .open_file (f.get_path ());
            if (f != null)
            {
                (window.window_panels.get_nth_page (WindowStatus.OPENEDFILES) as OpenedFilesPanel).add_file (file);
                (window.window_panels.get_nth_page (WindowStatus.OPENEDFILES) as OpenedFilesPanel).file_activated (file);
            }
        }

    }
}