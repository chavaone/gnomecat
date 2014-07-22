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

namespace GNOMECAT.UI {

    public class RecentFilesWidget : Gtk.ListBox
    {

        public signal void file_activated (GNOMECAT.File file);

        construct
        {
            Gtk.RecentManager.get_default ().changed.connect (on_files_changed);
            on_files_changed ();
            row_activated.connect (on_row_activated);
        }

        private void on_files_changed ()
        {
            this.foreach ((m) => {this.remove (m);});

            foreach (Gtk.RecentInfo f in Gtk.RecentManager.get_default ().get_items ())
            {

                if (! f.exists ())
                    continue;

                string file_path;
                try
                {
                    file_path = Filename.from_uri (f.get_uri ());
                }
                catch (Error e){
                    continue;
                }

                if (file_path.substring (file_path.length - 3) == ".po")
                {
                    add (new PoFileRow (new GNOMECAT.PoFiles.PoFileProxy.full (file_path, null)));
                }
            }
        }

        private void on_row_activated (Gtk.ListBoxRow row)
        {
            GNOMECAT.PoFiles.PoFile fp = (row as PoFileRow).file;
            file_activated (new GNOMECAT.PoFiles.PoFile.full (fp.path, null));
        }
    }
}