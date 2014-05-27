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
using GNOMECAT.Search;


namespace GNOMECAT.UI
{
    [GtkTemplate (ui = "/info/aquelando/gnomecat/ui/window.ui")]
    public class Window : Gtk.ApplicationWindow
    {
        [GtkChild]
        private Gtk.SearchBar search_bar;
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
        [GtkChild]
        private Gtk.Separator separator_search;
        [GtkChild]
        private Gtk.Box advanced_box;
        [GtkChild]
        private Gtk.ToggleButton advanced_search_button;
        [GtkChild]
        private Gtk.Button replace_button;
        [GtkChild]
        private Gtk.Entry search_entry;
        [GtkChild]
        private Gtk.Entry replace_entry;
        [GtkChild]
        private Gtk.CheckButton translated_messages;
        [GtkChild]
        private Gtk.CheckButton untranslated_messages;
        [GtkChild]
        private Gtk.CheckButton fuzzy_messages;
        [GtkChild]
        private Gtk.CheckButton original_text;
        [GtkChild]
        private Gtk.CheckButton translation_text;
        [GtkChild]
        private Gtk.CheckButton plurals_text;
        [GtkChild]
        private Gtk.Box window_box;
        [GtkChild]
        public Gtk.Notebook headerbar;
        [GtkChild]
        public Gtk.StackSwitcher preferences_stack;

        public GNOMECAT.UI.Notebook notebook;

        private bool _advanded_search_enabled;
        public bool advanded_search_enabled
        {
            get
            {
                return _advanded_search_enabled;
            }
            set
            {
                _advanded_search_enabled = value;

                separator_search.visible = value;
                advanced_box.visible = value;
                replace_button.visible = value;
                replace_entry.visible = value;
            }
        }

        public bool search_enabled
        {
            get
            {
                return search_bar.search_mode_enabled;
            }
            set
            {
                search_bar.search_mode_enabled = value;

                if (active_search == null) return;

                if (value) active_search.select ();
                else active_search.deselect ();
            }
        }

        private GNOMECAT.Search.Search _active_search;
        public GNOMECAT.Search.Search active_search
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

        public Gtk.Widget? work_pannel
        {
            get
            {
                if (window_box.get_children ().length () == 1)
                    return null;
                return window_box.get_children ().nth_data (1);
            }
            set
            {
                Gtk.Widget old = work_pannel;
                if(old != null)
                    window_box.remove (old);
                if(value != null)
                    window_box.pack_end(value);
            }
        }

        public signal void file_changed (GNOMECAT.FileProject.File? file);
        public signal void project_changed (GNOMECAT.FileProject.Project? project);

        private const GLib.ActionEntry[] action_entries = {
            { "edit-undo", on_edit_undo },
            { "edit-redo", on_edit_redo },
            { "search-next", on_search_next },
            { "search-previous", on_search_previous },
            { "edit-save", on_edit_save},
            { "go-next", on_go_next},
            { "go-previous", on_go_previous},
            { "go-next-untranslated", on_go_next_untranslated},
            { "go-previous-untranslated", on_go_previous_untranslated},
            { "go-next-translated", on_go_next_translated},
            { "go-previous-translated", on_go_previous_translated},
            { "go-next-fuzzy", on_go_next_fuzzy},
            { "go-previous-fuzzy", on_go_previous_fuzzy},
            { "on-search-replace", on_search_replace}
        };

        public Window (GNOMECAT.Application app)
        {
            Object (application: app);

            notebook = new GNOMECAT.UI.Notebook ();
            work_pannel = notebook;

            this.recentfilemenu.filter = new RecentFilter ();
            foreach (string ext in (this.application as GNOMECAT.Application).extensions)
            {
                this.recentfilemenu.filter.add_pattern ("*." + ext);
            }

            this.recentprojectmenu.filter = new RecentFilter ();
            this.recentprojectmenu.filter.add_pattern ("*/");
        }

        construct
        {
            add_action_entries (action_entries, this);

            this.searchbutton.bind_property ("active", this,
                "search_enabled", BindingFlags.BIDIRECTIONAL);

            this.advanced_search_button.bind_property ("active", this,
                "advanded_search_enabled", BindingFlags.BIDIRECTIONAL);

            this.file_changed.connect (on_file_changed);
            this.project_changed.connect (on_project_changed);
        }

        public void add_file (GNOMECAT.FileProject.File f)
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
            notebook.add_tab (f_tab);
            f_tab.show ();
            notebook.set_current_page (notebook.page_num (f_tab));
        }

        public void add_project (GNOMECAT.FileProject.Project p)
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
            notebook.add_tab (p_tab);
            p_tab.show ();
            notebook.set_current_page (notebook.page_num (p_tab));
        }

        private void on_go_next ()
        {
            Tab t = notebook.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_next ();
            }
        }

        private void on_go_previous ()
        {
            Tab t = notebook.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_previous ();
            }
        }

        private void on_go_next_fuzzy ()
        {
            Tab t = notebook.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_next_fuzzy ();
            }
        }

        private void on_go_previous_fuzzy ()
        {
            Tab t = notebook.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_previous_fuzzy ();
            }
        }

        private void on_go_next_translated ()
        {
            Tab t = notebook.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_next_translated ();
            }
        }

        private void on_go_previous_translated ()
        {
            Tab t = notebook.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_previous_translated ();
            }
        }

        private void on_go_next_untranslated ()
        {
            Tab t = notebook.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_next_untranslated ();
            }
        }

        private void on_go_previous_untranslated ()
        {
            Tab t = notebook.get_active_tab ();
            if (t is FileTab)
            {
                (t as FileTab).go_previous_untranslated ();
            }
        }

        private void on_edit_save ()
        {
            Tab t = notebook.get_active_tab ();
            if (! (t is FileTab))
                return;
            FileTab ft = t as FileTab;
            ft.file.save_file ();
        }

        private void on_edit_undo ()
        {
            Tab t = notebook.get_active_tab ();
            if (! (t is FileTab))
                return;
            FileTab ft = t as FileTab;
            ft.undo ();
        }

        private void on_edit_redo ()
        {
            Tab t = notebook.get_active_tab ();
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

        private void on_search_replace ()
        {
            if (active_search == null) return;
            active_search.replace_text = replace_entry.get_text ();
            active_search.replace ();
        }

        private void on_file_changed (Window src, GNOMECAT.FileProject.File? file)
        {
            if (file == null)
            {
                this.label_title.set_text ("GNOMECAT");
                this.progressbar_title.hide ();
            }
            else
            {
                this.label_title.set_text ("GNOMECAT - " + file.name);
                set_progress_bar_info (file.number_of_translated,
                    file.number_of_untranslated, file.number_of_fuzzy);
            }
        }

        private void on_project_changed (Window src, GNOMECAT.FileProject.Project? project)
        {
            if (project == null)
            {
                this.label_title.set_text ("GNOMECAT");
                this.progressbar_title.hide ();
            }
            else
            {
                this.label_title.set_text ("GNOMECAT - " +  project.name);
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
        private void on_search_changed (Gtk.Widget w)
        {
            if (search_entry.get_text () == "")
            {
                this.active_search = null;
            }
            else if (true) //FIXME: include project searches
            {
                init_file_search ((notebook.get_active_tab () as FileTab).file,
                    translated_messages.active, untranslated_messages.active,
                    fuzzy_messages.active, original_text.active, translation_text.active,
                    plurals_text.active, search_entry.get_text (), "");

                this.active_search.next ();
            }
            else
            {
                return; //FIXME: include project searches
            }
        }

        [GtkCallback]
        private void on_open_recent_file ()
        {
            string uri = this.recentfilemenu.get_current_uri ();
            GNOMECAT.FileProject.File f = GNOMECAT.Application.get_default ()
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
            var app = GNOMECAT.Application.get_default ();
            foreach (string ext in (app as GNOMECAT.Application).extensions)
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
                GNOMECAT.FileProject.File? f = GNOMECAT.Application.get_default ()
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
                    this.add_project (new GNOMECAT.FileProject.Project (f.get_path ()));
            }
        }

        [GtkCallback]
        private void on_settings ()
        {
            GNOMECAT.UI.PreferencesDialog dialog = new PreferencesDialog ();

            dialog.run ();
            dialog.destroy ();
        }

        public bool select (GNOMECAT.SelectLevel level,
            GNOMECAT.FileProject.MessageFragment? fragment)
        {
            return notebook.select (level, fragment);
        }

        public void deselect (GNOMECAT.SelectLevel level,
            GNOMECAT.FileProject.MessageFragment? fragment)
        {
            notebook.deselect (level, fragment);
        }

        private void init_file_search (GNOMECAT.FileProject.File file, bool translated_messages,
            bool untranslated_messages, bool fuzzy_messages, bool original_text,
            bool translation_text, bool plurals_text, string search_text, string replace_text)
        {
            active_search = new FileSearch (file, translated_messages, untranslated_messages,
                fuzzy_messages, original_text, translation_text, search_text, replace_text);
        }
    }
}