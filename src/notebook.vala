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



namespace GNOMECAT.UI
{

    [GtkTemplate (ui = "/info/aquelando/gnomecat/ui/notebook.ui")]
    public class Notebook : Gtk.Notebook
    {

        public Notebook ()
        {}

        public void add_tab (Tab t)
        {
            this.append_page (t, t.label);
            this.set_tab_detachable (t, true);
            this.set_tab_reorderable (t, true);
        }

        public Tab get_active_tab ()
        {
            int page_number = this.get_current_page ();
            return this.get_nth_page (page_number) as Tab;
        }

        [GtkCallback]
        private void on_switch_page (Gtk.Widget src,
                                    uint page)
        {
            int page_num = int.parse (page.to_string ()); //FIXME
            Tab t = this.get_nth_page (page_num) as Tab;
            GNOMECAT.UI.Window win = this.get_parent_window () as GNOMECAT.UI.Window;

            if (t is FileTab)
            {
                win.file_changed (t.file);
            }
            else
            {
                win.project_changed (t.project);
            }
        }

        [GtkCallback]
        private void on_page_added (Gtk.Widget pate, uint page_num)
        {
            if (this.get_n_pages () > 1)
                this.show_tabs = true;
        }

        [GtkCallback]
        private void on_page_removed (Gtk.Widget pate, uint page_num)
        {
            if (this.get_n_pages () == 0 &&
                GNOMECAT.Application.get_default ().get_windows ().length () != 1)
                (this.get_parent_window () as GNOMECAT.UI.Window).close ();
            if (this.get_n_pages () <= 1)
                this.show_tabs = false;
        }

        public bool select (GNOMECAT.SelectLevel level,
            GNOMECAT.FileProject.MessageFragment? fragment)
        {
            for (int n_pages = this.get_n_pages(); n_pages >= 0; n_pages--)
            {
                if ((this.get_nth_page (n_pages) as Tab).file == fragment.file)
                {
                    this.set_current_page (n_pages);
                    if (level != SelectLevel.FILE)
                    {
                        (this.get_nth_page (n_pages) as FileTab).select (level,
                            fragment);
                    }
                    return true;
                }
            }
            return false;
        }

        public void deselect (GNOMECAT.SelectLevel level,
            GNOMECAT.FileProject.MessageFragment? fragment)
        {
            for (int n_pages = this.get_n_pages(); n_pages >= 0; n_pages--)
            {
                if ((this.get_nth_page (n_pages) as Tab).file == fragment.file)
                {
                    if (level != SelectLevel.FILE)
                    {
                        (this.get_nth_page (n_pages) as FileTab).deselect (level,
                            fragment);
                    }
                }
            }
        }

        [GtkCallback]
        private unowned Gtk.Notebook on_create_window (Gtk.Widget page, int x, int y)
        {
            var win = new GNOMECAT.UI.Window ((this.get_parent_window () as
                GNOMECAT.UI.Window).application as GNOMECAT.Application);
            win.show ();
            return win.notebook;
        }
    }
}