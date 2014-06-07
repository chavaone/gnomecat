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
        OPENEDFILES = 0,
        EDIT = 1,
        PREFERENCES = 2,
        OTHER
    }

    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/window.ui")]
    public class Window : Gtk.ApplicationWindow
    {
        [GtkChild]
        public Gtk.Notebook window_panels;
        public GNOMECAT.UI.ToolBar headerbar;


        public GNOMECAT.FileProject.File file
        {
            get {
                return (window_panels.get_nth_page (WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).file;
            }
            set {
                (window_panels.get_nth_page(WindowStatus.OPENEDFILES) as GNOMECAT.UI.OpenedFilesPanel).add_file(value);
                set_panel(WindowStatus.EDIT);
                (window_panels.get_nth_page (WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).file = value;
            }
        }

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
            headerbar.preferences_switch.stack = window_panels.get_nth_page(WindowStatus.PREFERENCES) as Gtk.Stack;

            headerbar.searchbutton.bind_property ("active",
                window_panels.get_nth_page(WindowStatus.EDIT) as EditPanel,
                "search_enabled", BindingFlags.BIDIRECTIONAL);
        }

        construct
        {
            add_action_entries (action_entries, this);
        }

        public void set_panel (WindowStatus status, Panel? custom_panel = null)
        {
            assert(status != WindowStatus.OTHER || custom_panel != null);

            int page_num = status == WindowStatus.OTHER ? window_panels.append_page(custom_panel as Gtk.Widget, null) : status;
            window_panels.page = page_num;
            (window_panels.get_nth_page (page_num) as Panel).window_page = page_num;
            headerbar.set_toolbar_mode ((window_panels.get_nth_page (page_num) as Panel).toolbarmode);
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
            set_panel (WindowStatus.PREFERENCES);
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

        [GtkCallback]
        private void on_file_changed (GNOMECAT.FileProject.File? file)
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

        [GtkCallback]
        private void on_file_activated (GNOMECAT.FileProject.File? file)
        {
            set_panel (WindowStatus.EDIT);
            (window_panels.get_nth_page (WindowStatus.EDIT) as GNOMECAT.UI.EditPanel).file = file;
        }
    }
}