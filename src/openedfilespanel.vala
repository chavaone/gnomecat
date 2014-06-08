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

        public signal void file_activated (GNOMECAT.FileProject.File file);

        public void add_file (GNOMECAT.FileProject.File file)
        {
            bool exists = false;
            files.foreach (
                (fr) =>
                {
                    exists |= (fr as GNOMECAT.UI.FileListRow).file == file;
                }
            );
            if (! exists)
                files.add (new FileListRow (file));
        }

        public void remove_file (GNOMECAT.FileProject.File file)
        {
            files.foreach (
                (fr) =>
                {
                    if ((fr as GNOMECAT.UI.FileListRow).file == file)
                    {
                        files.remove(fr);
                    }
                }
            );
        }

        public void on_open_file (GNOMECAT.UI.Window window)
        {
            window.set_panel(WindowStatus.OPEN);
        }

        [GtkCallback]
        private void on_row_activated (Gtk.ListBox list_box, Gtk.ListBoxRow row)
        {
            file_activated ((row as GNOMECAT.UI.FileListRow).file);
        }
    }


    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/filelistrow.ui")]
    public class FileListRow : Gtk.ListBoxRow
    {
        [GtkChild]
        private Gtk.Label label_file_name;
        [GtkChild]
        private Gtk.Label label_info_trans;
        [GtkChild]
        private Gtk.ProgressBar progressbar_file;

        private GNOMECAT.FileProject.File _file;
        public GNOMECAT.FileProject.File file
        {
            get
            {
                return _file;
            }
            private set
            {
                _file = value;
                label_file_name.set_text (_file.name);
                label_info_trans.set_text ("%iT %iU %iF".printf (_file.number_of_translated,
                    _file.number_of_untranslated, _file.number_of_fuzzy));
                double total = _file.number_of_translated + _file.number_of_untranslated
                + _file.number_of_fuzzy;
                progressbar_file.fraction = _file.number_of_translated / total;
            }
        }

        public FileListRow (GNOMECAT.FileProject.File f)
        {
            file = f;
        }
    }
}