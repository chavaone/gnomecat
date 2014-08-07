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
    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/openedfilespanel.ui")]
    public class OpenedFilesPanel : Gtk.Box, GNOMECAT.UI.Panel
    {
        [GtkChild]
        private Gtk.ListBox files;

        public GNOMECAT.UI.ToolBarMode toolbarmode
        {
            get
            {
                return GNOMECAT.UI.ToolBarMode.OPENEDFILES;
            }
        }

        public int window_page {get; set;}

        public signal void file_activated (GNOMECAT.File file);

        public void add_file (GNOMECAT.File file)
        {
            bool exists = false;
            files.foreach (
                (fr) =>
                {
                    exists |= (fr as GNOMECAT.UI.PoFileRow).file == file;
                }
            );
            if (! exists && file is GNOMECAT.PoFiles.PoFile)
                files.add (new PoFileRow (file as GNOMECAT.PoFiles.PoFile));
        }

        public void remove_file (GNOMECAT.File file)
        {
            files.foreach (
                (fr) =>
                {
                    if ((fr as GNOMECAT.UI.PoFileRow).file == file)
                    {
                        files.remove (fr);
                    }
                }
            );
        }

        public void on_open_file (GNOMECAT.UI.Window window)
        {
            window.set_panel (WindowStatus.OPEN);
        }

        [GtkCallback]
        private void on_row_activated (Gtk.ListBox list_box, Gtk.ListBoxRow row)
        {
            file_activated ((row as GNOMECAT.UI.PoFileRow).file);
        }
    }
}