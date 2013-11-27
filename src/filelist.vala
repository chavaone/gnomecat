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

using Gtk;
using GNOMECAT.FileProject;

namespace GNOMECAT.UI
{
    [GtkTemplate (ui = "/info/aquelando/gnomecat/ui/filelist.ui")]
    public class FileListWidget : Gtk.Box
    {
        [GtkChild]
        private ListBox file_list_box;

        private Project _project;
        public Project project
        {
            get
            {
                return _project;
            }
            private set
            {
                _project = value;
                foreach (Widget w in file_list_box.get_children ())
                    file_list_box.remove (w);
                foreach (GNOMECAT.FileProject.File f in _project.files)
                    add_file (f);
                _project.file_added.connect (add_file);
            }
        }

        public FileListWidget (Project proj)
        {
            project = proj;
        }

        [GtkCallback]
        private void on_row_activated (ListBox list_box, ListBoxRow row)
        {
            (GNOMECAT.Application.get_default ().get_active_window () as GNOMECAT.UI.Window)
                .add_file ((row as FileListRow).file);
        }

        private void add_file (GNOMECAT.FileProject.File file)
        {
            file_list_box.add (new FileListRow (file));
        }
    }


    [GtkTemplate (ui = "/info/aquelando/gnomecat/ui/filelistrow.ui")]
    public class FileListRow : ListBoxRow
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