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
            (window_panels.get_nth_page(window_panels.page) as Panel).on_go_next (this);
        }

        private void on_go_previous ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_go_previous (this);
        }

        private void on_go_next_fuzzy ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_go_next_fuzzy (this);
        }

        private void on_go_previous_fuzzy ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_go_previous_fuzzy (this);
        }

        private void on_go_next_translated ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_go_next_translated (this);
        }

        private void on_go_previous_translated ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_go_previous_translated (this);
        }

        private void on_go_next_untranslated ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_go_next_untranslated (this);
        }

        private void on_go_previous_untranslated ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_go_previous_untranslated (this);
        }

        private void on_edit_save ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_edit_save (this);
        }

        private void on_edit_undo ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_edit_undo (this);
        }

        private void on_edit_redo ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_edit_redo (this);
        }

        private void on_search_next ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_search_next (this);
        }

        private void on_search_previous ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_search_previous (this);
        }

        private void on_search_replace ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_search_replace (this);
        }

        private void on_open_file ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_open_file (this);
        }

        private void on_done ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_done (this);
        }

        private void on_back ()
        {
            (window_panels.get_nth_page(window_panels.page) as Panel).on_back (this);
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

    }
}