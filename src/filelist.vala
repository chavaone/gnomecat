/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of GnomeCAT
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
 *
 * GnomeCAT is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * GnomeCAT is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with GnomeCAT. If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;
using GnomeCAT.FileProject;

namespace GnomeCAT.UI
{
    [GtkTemplate (ui = "/info/aquelando/gnomecat/ui/filelist.ui")]
    public class FileListWidget : Gtk.Box
    {
        [GtkChild]
        private ListBox file_list_box;

        public Project project {get; private set;}

        public FileListWidget.with_project (Project proj)
        {
            this.project = proj;

            foreach (GnomeCAT.FileProject.File f in this.project.files)
            {
                this.add_file (f);
            }
        }

        public void add_file (GnomeCAT.FileProject.File f)
        {
            this.file_list_box.add (new FileListRow (f));
        }

        [GtkCallback]
        private void on_row_activated (ListBox list_box, ListBoxRow row)
        {
            var w = this.get_toplevel ().parent.parent.parent.parent as GnomeCAT.UI.Window;
            w.add_file ((row as FileListRow).file);
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

        public GnomeCAT.FileProject.File file {get; private set;}

        public FileListRow (GnomeCAT.FileProject.File f)
        {
            this.file = f;
            label_file_name.set_text ("f.name");
            label_info_trans.set_text ("%iT %iU %iF".printf (f.number_of_translated,
                f.number_of_untranslated, f.number_of_fuzzy));
            float fraction = f.number_of_translated / f.number_of_messages;
            progressbar_file.set_fraction (fraction);
        }
    }
}