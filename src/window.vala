/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of valacat
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
 *
 * valacat is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * valacat is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with valacat. If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;
using ValaCAT.Search;


namespace ValaCAT.UI
{
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/window.ui")]
    public class Window : Gtk.ApplicationWindow
    {
        [GtkChild]
        private Gtk.HeaderBar headerbar;
        [GtkChild]
        private Gtk.SearchEntry search_entry;
        [GtkChild]
        private Gtk.SearchBar search_bar;
        [GtkChild]
        private Gtk.Notebook notebook;
        [GtkChild]
        private Gtk.ToggleButton searchbutton;
        [GtkChild]
        private Gtk.Label label_title;
        [GtkChild]
        private Gtk.ProgressBar progressbar_title;
        [GtkChild]
        private Gtk.RecentChooserMenu recentfilemenu;
        [GtkChild]
        private Gtk.RecentChooserMenu recentprojectmenu;

        private ValaCAT.UI.SearchDialog search_dialog;
        public ValaCAT.Search.Search active_search {get; set;}

        public signal void file_changed (ValaCAT.FileProject.File? file);
        public signal void project_changed (ValaCAT.FileProject.Project? project);


        private const GLib.ActionEntry[] action_entries = {
            { "edit-undo", on_edit_undo },
            { "edit-redo", on_edit_redo },
            { "search-next", on_search_next },
            { "search-previous", on_search_previous },
            { "edit-save", on_edit_save},
            { "search-advanced", on_search_advanded},
            { "go-next", on_go_next},
            { "go-previous", on_go_previous},
            { "go-next-untranslated", on_go_next_untranslated},
            { "go-previous-untranslated", on_go_previous_untranslated},
            { "go-next-translated", on_go_next_translated},
            { "go-previous-translated", on_go_previous_translated},
            { "go-next-fuzzy", on_go_next_fuzzy},
            { "go-previous-fuzzy", on_go_previous_fuzzy},
            { "open-file", on_open_file}
        };


        public Window (ValaCAT.Application.Application app)
        {
            Object(application: app);
        }

        construct
        {
            add_action_entries (action_entries, this);

            this.searchbutton.bind_property("active", this.search_bar,
                "search-mode-enabled", BindingFlags.BIDIRECTIONAL);

            this.file_changed.connect(on_file_changed);
            this.project_changed.connect(on_project_changed);

            this.recentfilemenu.filter = new RecentFilter ();
            foreach (string ext in (this.application as ValaCAT.Application.Application).extensions)
            {
                this.recentfilemenu.filter.add_pattern ("*." + ext);
            }
        }

        public void add_file (ValaCAT.FileProject.File f)
        {
            int number_of_pages = notebook.get_n_pages ();
            for (int i = 0; i < number_of_pages; i++)
            {
                var tab = notebook.get_nth_page (i);
                if (tab is FileTab && (tab as FileTab).file == f)
                {
                    notebook.set_current_page (i);
                    return;
                }
            }
            FileTab f_tab = new FileTab (f);
            this.add_tab (f_tab);
            f_tab.show_all ();
            notebook.set_current_page (notebook.page_num (f_tab));
        }

        public void add_project (ValaCAT.FileProject.Project p)
        {
            int number_of_pages = notebook.get_n_pages ();
            for (int i = 0; i < number_of_pages; i++)
            {
                var tab = notebook.get_nth_page (i);
                if (tab is ProjectTab && (tab as ProjectTab).project == p)
                {
                    notebook.set_current_page (i);
                    return;
                }
            }

            ProjectTab p_tab = new ProjectTab (p);
            this.add_tab (p_tab);
            p_tab.show_all ();
            notebook.set_current_page (notebook.page_num (p_tab));
        }


        public void add_tab (Tab t)
        {
            this.notebook.append_page (t, t.label);
            this.notebook.set_tab_detachable (t, true);
            this.notebook.set_tab_reorderable (t, true);
        }

        public Tab get_active_tab ()
        {
            int page_number = this.notebook.get_current_page ();
            return this.notebook.get_nth_page (page_number) as Tab;
        }

        void on_go_next ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_next ();
            }
        }

        void on_go_previous ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_previous ();
            }
        }

        void on_go_next_fuzzy ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_next_fuzzy ();
            }
        }

        void on_go_previous_fuzzy ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_previous_fuzzy ();
            }
        }

        void on_go_next_translated ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_next_translated ();
            }
        }

        void on_go_previous_translated ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_previous_translated ();
            }
        }

        void on_go_next_untranslated ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_next_untranslated ();
            }
        }

        void on_go_previous_untranslated ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_previous_untranslated ();
            }
        }

        void on_search_advanded ()
        {
            if (this.search_dialog == null)
                this.search_dialog = new SearchDialog(this);
            this.search_dialog.show_all();
        }

        void on_edit_save ()
        {
            Tab t = this.get_active_tab ();
            if (! (t is FileTab))
                return;
            FileTab ft = t as FileTab;
            ft.file.save_file ();
        }

        void on_edit_undo ()
        {
            Tab t = this.get_active_tab ();
            if (! (t is FileTab))
                return;
            FileTab ft = t as FileTab;
            ft.undo ();
        }

        void on_edit_redo ()
        {
            Tab t = this.get_active_tab ();
            if (! (t is FileTab))
                return;
            FileTab ft = t as FileTab;
            ft.redo ();
        }

        void on_search_next ()
        {
            if (this.active_search == null)
                return;
            this.active_search.next_item ();
        }

            void on_search_previous ()
        {
            if (this.active_search == null)
                return;
            this.active_search.previous_item ();
        }

        public void on_file_changed (Window src, ValaCAT.FileProject.File? file)
        {
            if (file == null)
            {
                this.label_title.set_text ("ValaCAT");
                this.progressbar_title.hide ();
            }
            else
            {
                this.label_title.set_text ("filename"); //TODO
                set_progress_bar_info (file.number_of_translated,
                    file.number_of_untranslated, file.number_of_fuzzy);
            }
        }

        private void set_progress_bar_info (int translated, int untranslated, int fuzzy)
        {
                progressbar_title.show ();
                progressbar_title.set_text (_("%iT + %iU + %iF").printf (translated,
                    untranslated, fuzzy));
                double total = translated + untranslated + fuzzy;
                progressbar_title.fraction = translated / total;
        }



        public void on_project_changed (Window src, ValaCAT.FileProject.Project? project)
        {
            //TODO
        }

        [GtkCallback]
        private void on_switch_page (Gtk.Widget src,
                                    uint page)
        {
            int page_num = int.parse(page.to_string()); //FIXME
            Tab t = this.notebook.get_nth_page (page_num) as Tab;
            this.file_changed (t.file);
            this.project_changed (t.project);
        }

        [GtkCallback]
        private void on_search_changed (Gtk.SearchEntry entry)
        {
            if (this.active_search != null)
                this.active_search.disable();
            if (entry.get_text() == "")
            {
                this.active_search = null;
            }
            else
            {
                this.active_search = new FileSearch (   this.get_active_tab() as FileTab,
                                                        true,
                                                        true,
                                                        true,
                                                        true,
                                                        true,
                                                        false,
                                                        true,
                                                        entry.get_text (),
                                                        "");

                this.active_search.next_item();
            }

        }

        [GtkCallback]
        private weak Gtk.Notebook on_create_window (Gtk.Widget page, int x, int y)
        {
            var win = new ValaCAT.UI.Window (this.application as ValaCAT.Application.Application);
            win.show_all ();
            return win.notebook;
        }

        [GtkCallback]
        private void on_page_removed (Gtk.Widget pate, uint page_num)
        {
            if (this.notebook.get_n_pages () == 0)
            {
                this.hide ();
            }
        }

        private void on_open_file ()
        {
        }

        [GtkCallback]
        private void on_open_recent_file ()
        {
            string uri = this.recentfilemenu.get_current_uri ();
            (this.application as ValaCAT.Application.Application).open_file (GLib.File.new_for_uri (uri), this);
        }

    }
}