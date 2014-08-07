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

 namespace GNOMECAT.UI
 {

    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/searchbar.ui")]
    public class SearchBar : Gtk.SearchBar
    {

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
        private Gtk.Separator separator_search;

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

        public signal void search_changed (GNOMECAT.SearchInfo? serch);

        construct {
            advanced_search_button.bind_property ("active", this,
                "advanded_search_enabled", BindingFlags.BIDIRECTIONAL);
        }

        public void get_focus ()
        {
            search_entry.grab_focus ();
        }

        [GtkCallback]
        private void on_search_changed (Gtk.Widget w)
        {
            SearchInfo search = null;
            if (search_entry.get_text () != "")
            {
                search = new SearchInfo (translated_messages.active,
                    untranslated_messages.active,
                    fuzzy_messages.active,
                    original_text.active,
                    translation_text.active,
                    plurals_text.active,
                    search_entry.get_text (),
                    replace_entry.get_text()
                    );
            }

            search_changed(search);
        }
    }
 }