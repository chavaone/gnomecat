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
using GnomeCAT.Search;


namespace GnomeCAT.UI
{
    [GtkTemplate (ui = "/info/aquelando/gnomecat/ui/window.ui")]
    public class Window : Gtk.ApplicationWindow
    {
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

        private GnomeCAT.Search.Search _active_search;
        public GnomeCAT.Search.Search active_search
        {
            get
            {
                return _active_search;
            }
            set
            {
                if (_active_search != null)
                    _active_search.deselect ();
                _active_search = value;
            }
        }

        public signal void file_changed (GnomeCAT.FileProject.File? file);
        public signal void project_changed (GnomeCAT.FileProject.Project? project);

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
            { "go-previous-fuzzy", on_go_previous_fuzzy}
        };

        public Window (GnomeCAT.Application app)
        {
            Object (application: app);

            this.recentfilemenu.filter = new RecentFilter ();
            foreach (string ext in (this.application as GnomeCAT.Application).extensions)
            {
                this.recentfilemenu.filter.add_pattern ("*." + ext);
            }

            this.recentprojectmenu.filter = new RecentFilter ();
            this.recentprojectmenu.filter.add_pattern ("*/");
        }

        construct
        {
            add_action_entries (action_entries, this);

            this.searchbutton.bind_property ("active", this.search_bar,
                "search-mode-enabled", BindingFlags.BIDIRECTIONAL);

            this.file_changed.connect (on_file_changed);
            this.project_changed.connect (on_project_changed);
        }

        public void add_file (GnomeCAT.FileProject.File f)
        {
            int number_of_pages = notebook.get_n_pages ();
            for (int i = 0; i < number_of_pages; i++)
            {
                var tab = notebook.get_nth_page (i);
                if (tab is FileTab && (tab as FileTab).file.path == f.path)
                {
                    notebook.set_current_page (i);
                    return;
                }
            }
            FileTab f_tab = new FileTab (f);
            this.add_tab (f_tab);
            f_tab.show ();
            notebook.set_current_page (notebook.page_num (f_tab));
        }

        public void add_project (GnomeCAT.FileProject.Project p)
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
            p_tab.show ();
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

        private void on_go_next ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_next ();
            }
        }

        private void on_go_previous ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_previous ();
            }
        }

        private void on_go_next_fuzzy ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_next_fuzzy ();
            }
        }

        private void on_go_previous_fuzzy ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_previous_fuzzy ();
            }
        }

        private void on_go_next_translated ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_next_translated ();
            }
        }

        private void on_go_previous_translated ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_previous_translated ();
            }
        }

        private void on_go_next_untranslated ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_next_untranslated ();
            }
        }

        private void on_go_previous_untranslated ()
        {
            Tab t = this.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_previous_untranslated ();
            }
        }

        private void on_search_advanded ()
        {
            GnomeCAT.UI.SearchDialog dialog = new SearchDialog ();

            switch (dialog.run ())
            {
            case GnomeCAT.UI.SearchDialogResponses.CANCEL:
                break;
            case GnomeCAT.UI.SearchDialogResponses.SEARCH:
                ini_search (dialog, dialog.search_project, false, true, dialog.wrap_around);
                break;
            case GnomeCAT.UI.SearchDialogResponses.REPLACE:
                ini_search (dialog, dialog.search_project, true, true, dialog.wrap_around);
                break;
            case GnomeCAT.UI.SearchDialogResponses.REPLACEALL:
                ini_search (dialog, dialog.search_project, true, false, dialog.wrap_around);
                break;
            }

            dialog.destroy ();
        }

        private void ini_search (GnomeCAT.UI.SearchDialog dialog,
            bool project, bool replace, bool stop, bool wrap)
        {

            if (project)
            {
                //active_search = null;
            }
            else
            {
                active_search = new FileSearch ((get_active_tab () as FileTab).file,
                                                dialog.translated_messages,
                                                dialog.untranslated_messages,
                                                dialog.fuzzy_messages,
                                                dialog.original_text,
                                                dialog.translation_text,
                                                dialog.search_text,
                                                dialog.replace_text);
            }

            if (stop)
            {
                active_search.next ();
            }
            else
            {
                do
                {
                    active_search.next ();
                    active_search.replace ();
                } while (true); //FIXME
            }
        }

        private void on_edit_save ()
        {
            Tab t = this.get_active_tab ();
            if (! (t is FileTab))
                return;
            FileTab ft = t as FileTab;
            ft.file.save_file ();
        }

        private void on_edit_undo ()
        {
            Tab t = this.get_active_tab ();
            if (! (t is FileTab))
                return;
            FileTab ft = t as FileTab;
            ft.undo ();
        }

        private void on_edit_redo ()
        {
            Tab t = this.get_active_tab ();
            if (! (t is FileTab))
                return;
            FileTab ft = t as FileTab;
            ft.redo ();
        }

        private void on_search_next ()
        {
            if (this.active_search == null)
                return;
            this.active_search.next ();
        }

        private void on_search_previous ()
        {
            if (this.active_search == null)
                return;
            this.active_search.previous ();
        }

        private  void on_file_changed (Window src, GnomeCAT.FileProject.File? file)
        {
            if (file == null)
            {
                this.label_title.set_text ("GnomeCAT");
                this.progressbar_title.hide ();
            }
            else
            {
                this.label_title.set_text ("GnomeCAT - " + file.name);
                set_progress_bar_info (file.number_of_translated,
                    file.number_of_untranslated, file.number_of_fuzzy);
            }
        }

        private  void on_project_changed (Window src, GnomeCAT.FileProject.Project? project)
        {
            if (project == null)
            {
                this.label_title.set_text ("GnomeCAT");
                this.progressbar_title.hide ();
            }
            else
            {
                this.label_title.set_text ("GnomeCAT - " +  project.name);
                set_progress_bar_info (project.number_of_translated,
                    project.number_of_untranslated, project.number_of_fuzzy);
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

        [GtkCallback]
        private void on_switch_page (Gtk.Widget src,
                                    uint page)
        {
            int page_num = int.parse (page.to_string ()); //FIXME
            Tab t = this.notebook.get_nth_page (page_num) as Tab;

            if (t is FileTab)
            {
                this.file_changed (t.file);
            }
            else
            {
                this.project_changed (t.project);
            }
        }

        [GtkCallback]
        private void on_search_changed (Gtk.SearchEntry entry)
        {
            if (entry.get_text () == "")
            {
                this.active_search = null;
            }
            else
            {
                this.active_search = new FileSearch ((this.get_active_tab () as FileTab).file,
                                                    true,
                                                    true,
                                                    true,
                                                    true,
                                                    true,
                                                    entry.get_text (),
                                                    "");

                this.active_search.next ();
            }
        }

        [GtkCallback]
        private void on_search_button_clicked ()
        {
            if (active_search == null)
                return;

            if (this.searchbutton.get_active ())
            {
                active_search.select ();
            }
            else
            {
                active_search.deselect ();
            }
        }

        [GtkCallback]
        private unowned Gtk.Notebook on_create_window (Gtk.Widget page, int x, int y)
        {
            var win = new GnomeCAT.UI.Window (this.application as GnomeCAT.Application);
            win.show ();
            return win.notebook;
        }

        [GtkCallback]
        private void on_page_added (Gtk.Widget pate, uint page_num)
        {
            if (notebook.get_n_pages () > 1)
                notebook.show_tabs = true;
        }

        [GtkCallback]
        private void on_page_removed (Gtk.Widget pate, uint page_num)
        {
            if (notebook.get_n_pages () == 0 &&
                GnomeCAT.Application.get_default ().get_windows ().length () != 1)
                this.close ();
            if (notebook.get_n_pages () <= 1)
                notebook.show_tabs = false;
        }

        [GtkCallback]
        private void on_open_recent_file ()
        {
            string uri = this.recentfilemenu.get_current_uri ();
            GnomeCAT.FileProject.File f = GnomeCAT.Application.get_default ()
                .open_file (GLib.File.new_for_uri (uri).get_path ());
            this.add_file (f);
        }

        [GtkCallback]
        private void on_open_file ()
        {
            Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (_("Select a file to open."),
                this, Gtk.FileChooserAction.OPEN,
                Gtk.Stock.CANCEL,
                Gtk.ResponseType.CANCEL,
                Gtk.Stock.OPEN,
                Gtk.ResponseType.ACCEPT);

            chooser.filter = new FileFilter ();
            var app = GnomeCAT.Application.get_default ();
            foreach (string ext in (app as GnomeCAT.Application).extensions)
            {
                chooser.filter.add_pattern ("*." + ext);
            }

            chooser.file_activated.connect ((src) => {open_file_from_chooser (src as FileChooserDialog);});

            if (chooser.run () == Gtk.ResponseType.ACCEPT)
                this.open_file_from_chooser (chooser);
            chooser.destroy ();
        }

        private void open_file_from_chooser (FileChooserDialog chooser)
        {
            foreach (string uri in chooser.get_uris ())
            {
                GnomeCAT.FileProject.File? f = GnomeCAT.Application.get_default ()
                    .open_file (GLib.File.new_for_uri (uri).get_path ());
                if (f != null)
                    this.add_file (f);
            }
        }

        [GtkCallback]
        private void on_open_project ()
        {
            Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (_("Select a file to open."),
                this, Gtk.FileChooserAction.SELECT_FOLDER,
                Gtk.Stock.CANCEL,
                Gtk.ResponseType.CANCEL,
                Gtk.Stock.OPEN,
                Gtk.ResponseType.ACCEPT);

            chooser.file_activated.connect ((src) => {
                open_project_from_chooser (src as FileChooserDialog);
            });

            if (chooser.run () == Gtk.ResponseType.ACCEPT)
                this.open_project_from_chooser (chooser);
            chooser.destroy ();
        }

        private void open_project_from_chooser (FileChooserDialog chooser)
        {
            foreach (string uri in chooser.get_uris ())
            {
                var f = GLib.File.new_for_uri (uri);
                if (f.get_path () != null)
                    this.add_project (new GnomeCAT.FileProject.Project (f.get_path ()));
            }
        }

        [GtkCallback]
        private void on_settings ()
        {
            GnomeCAT.UI.PreferencesDialog dialog = new PreferencesDialog ();

            dialog.run ();
            dialog.destroy ();
        }

        public bool select (GnomeCAT.SelectLevel level,
            GnomeCAT.FileProject.MessageFragment? fragment)
        {
            for (int n_pages = this.notebook.get_n_pages(); n_pages >= 0; n_pages--)
            {
                if ((notebook.get_nth_page (n_pages) as Tab).file == fragment.file)
                {
                    notebook.set_current_page (n_pages);
                    if (level != SelectLevel.FILE)
                    {
                        (notebook.get_nth_page (n_pages) as FileTab).select (level,
                            fragment);
                    }
                    return true;
                }
            }
            return false;
        }

        public void deselect (GnomeCAT.SelectLevel level,
            GnomeCAT.FileProject.MessageFragment? fragment)
        {
            for (int n_pages = this.notebook.get_n_pages(); n_pages >= 0; n_pages--)
            {
                if ((notebook.get_nth_page (n_pages) as Tab).file == fragment.file)
                {
                    if (level != SelectLevel.FILE)
                    {
                        (notebook.get_nth_page (n_pages) as FileTab).deselect (level,
                            fragment);
                    }
                }
            }
        }
    }
}