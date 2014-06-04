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

    public enum WindowStatus {
        WELLCOME,
        OPEN,
        OPENEDFILES,
        EDIT,
        PREFERENCES,
        OTHER
    }

    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/window.ui")]
    public class Window : Gtk.ApplicationWindow
    {
        [GtkChild]
        public Gtk.Notebook window_panels;
        public GNOMECAT.UI.ToolBar headerbar;

        public GNOMECAT.Callback custom_done_callback;
        public GNOMECAT.Callback custom_back_callback;


        public GNOMECAT.FileProject.File file
        {
            get {
                return (window_panels.get_nth_page (WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).file;
            }
            set {
                (window_panels.get_nth_page(WindowStatus.OPENEDFILES) as GNOMECAT.UI.OpenedFilesPanel).add_file(value);
                headerbar.set_edit_toolbar();
                window_panels.page = WindowStatus.EDIT;
                (window_panels.get_nth_page (WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).file = value;
            }
        }

        public signal void file_changed (GNOMECAT.FileProject.File? file);

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
            { "on-search-replace", on_search_replace},
            { "preferences", on_preferences},
            { "open-file", on_open_file},
            { "done", on_done},
            { "back", on_back},
            { "about", on_about}
        };

        public Window (GNOMECAT.Application app)
        {
            Object (application: app);

            headerbar = new ToolBar();
            set_titlebar(headerbar);

            window_panels.insert_page(new Gtk.Label("wellcome"), null, WindowStatus.WELLCOME); //Wellcome Panel
            window_panels.insert_page(new Gtk.Label("open"), null, WindowStatus.OPEN); //Open File
            window_panels.insert_page(new OpenedFilesPanel(), null, WindowStatus.OPENEDFILES); //Project
            window_panels.insert_page(new EditPanel(), null, WindowStatus.EDIT); //Edit Panel
            window_panels.insert_page(new PreferencesPanel(), null, WindowStatus.PREFERENCES); //Preferences Panel

            window_panels.page = WindowStatus.OPENEDFILES;
            headerbar.set_openedfiles_toolbar();

            (window_panels.get_nth_page(WindowStatus.OPENEDFILES) as GNOMECAT.UI.OpenedFilesPanel)
                .on_file_activated.connect( (file) =>
                    {
                        headerbar.set_edit_toolbar();
                        window_panels.page = WindowStatus.EDIT;
                        (window_panels.get_nth_page (WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).file = file;
                    });
            headerbar.preferences_switch.stack = window_panels.get_nth_page(WindowStatus.PREFERENCES) as Gtk.Stack;
        }

        construct
        {
            add_action_entries (action_entries, this);

            this.file_changed.connect (on_file_changed);
        }

        private void on_go_next ()
        {
            if (window_panels.get_current_page () == WindowStatus.EDIT)
            {
                (window_panels.get_nth_page(WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).go_next();
            }
        }

        private void on_go_previous ()
        {
            if (window_panels.get_current_page () == WindowStatus.EDIT)
            {
                (window_panels.get_nth_page(WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).go_previous ();
            }
        }

        private void on_go_next_fuzzy ()
        {
            if (window_panels.get_current_page () == WindowStatus.EDIT)
            {
                (window_panels.get_nth_page(WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).go_next_fuzzy ();
            }
        }

        private void on_go_previous_fuzzy ()
        {
            if (window_panels.get_current_page () == WindowStatus.EDIT)
            {
                (window_panels.get_nth_page(WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).go_previous_fuzzy ();
            }
        }

        private void on_go_next_translated ()
        {
            if (window_panels.get_current_page () == WindowStatus.EDIT)
            {
                (window_panels.get_nth_page(WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).go_next_translated ();
            }
        }

        private void on_go_previous_translated ()
        {
            if (window_panels.get_current_page () == WindowStatus.EDIT)
            {
                (window_panels.get_nth_page(WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).go_previous_translated ();
            }
        }

        private void on_go_next_untranslated ()
        {
            if (window_panels.get_current_page () == WindowStatus.EDIT)
            {
                (window_panels.get_nth_page(WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).go_next_untranslated ();
            }
        }

        private void on_go_previous_untranslated ()
        {
            if (window_panels.get_current_page () == WindowStatus.EDIT)
            {
                (window_panels.get_nth_page(WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).go_previous_untranslated ();
            }
        }

        private void on_edit_save ()
        {
            if (window_panels.get_current_page () == WindowStatus.EDIT)
            {
                (window_panels.get_nth_page(WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).file.save_file ();
            }
        }

        private void on_edit_undo ()
        {
           if (window_panels.get_current_page () == WindowStatus.EDIT)
           {
                (window_panels.get_nth_page(WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).undo ();
            }
        }

        private void on_edit_redo ()
        {
            if (window_panels.get_current_page () == WindowStatus.EDIT)
            {
                (window_panels.get_nth_page(WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).redo ();
            }
        }

        private void on_search_next ()
        {
            if (window_panels.get_current_page () == WindowStatus.EDIT)
            {
                (window_panels.get_nth_page(WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).search_next ();
            }
        }

        private void on_search_previous ()
        {
            if (window_panels.get_current_page () == WindowStatus.EDIT)
            {
                (window_panels.get_nth_page(WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).search_previous ();
            }
        }

        private void on_search_replace ()
        {
            if (window_panels.get_current_page () == WindowStatus.EDIT)
            {
                (window_panels.get_nth_page(WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).replace ();
            }
        }

        private void on_open_file ()
        {
            if (window_panels.page == WindowStatus.OPENEDFILES)
            {
                (window_panels.get_nth_page(WindowStatus.OPENEDFILES) as GNOMECAT.UI.OpenedFilesPanel).on_open_file (this);
            }
        }

        private void on_done ()
        {
            if (window_panels.page == WindowStatus.PREFERENCES)
            {
                window_panels.page = WindowStatus.EDIT;
                headerbar.set_edit_toolbar();
            }
            else if (window_panels.page == WindowStatus.OTHER)
            {
                custom_done_callback();
            }
        }

        private void on_back ()
        {
            if (window_panels.page == WindowStatus.OTHER)
            {
                custom_back_callback();
            }
            else if (window_panels.page == WindowStatus.EDIT)
            {
                window_panels.page = WindowStatus.OPENEDFILES;
                headerbar.set_openedfiles_toolbar();
            }
        }

        private void on_preferences ()
        {
            headerbar.set_preferences_toolbar();
            window_panels.page = WindowStatus.PREFERENCES;
        }

        public void on_about ()
        {
            const string copyright = "Copyright \xc2\xa9 2014 Marcos Chavarría Teijeiro\n";

            const string authors[] = {
                "Marcos Chavarría Teijeiro",
                null
            };

            Gtk.show_about_dialog (this,
                                   "program-name", _("GNOMECAT"),
                                   "logo-icon-name", "gnomecat",
                                   "version", Config.VERSION,
                                   "copyright", copyright,
                                   "authors", authors,
                                   "license-type", Gtk.License.GPL_3_0,
                                   "wrap-license", false,
                                   "translator-credits", _("translator-credits"),
                                   null);
        }


        private void on_file_changed (Window src, GNOMECAT.FileProject.File? file)
        {
            if (file == null)
            {
                headerbar.edit_label_title.set_text ("GNOMECAT");
                headerbar.progressbar_title.hide ();
            }
            else
            {
                headerbar.edit_label_title.set_text ("GNOMECAT - " + file.name);
                headerbar.set_progressbar_info (file.number_of_translated,
                    file.number_of_untranslated, file.number_of_fuzzy);
            }
        }

        public void do_open_file (GLib.File f)
        {
            GNOMECAT.FileProject.File? file = GNOMECAT.Application.get_default ()
                    .open_file (f.get_path ());
            if (f != null) this.file = file;
        }


        //DEPRECATED

        /*
        construct{
                    this.searchbutton.bind_property ("active", this,
                "search_enabled", BindingFlags.BIDIRECTIONAL);
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

        */
    }
}