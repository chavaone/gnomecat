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

using GNOMECAT;
using GNOMECAT.FileProject;
using GNOMECAT.UI;
using GNOMECAT.Search;
using GNOMECAT.Navigator;
using GNOMECAT.Iterators;
using Gee;

namespace GNOMECAT.UI {

    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/editpanel.ui")]
    public class EditPanel : Gtk.Box, GNOMECAT.UI.Panel
    {

        [GtkChild]
        public SearchBar searchbar;

        [GtkChild]
        public MessageListWidget message_list;

        [GtkChild]
        public HintPanelWidget hints_panel;

        [GtkChild]
        public MessageEditor message_editor;

        public GNOMECAT.FileProject.File? _file;
        public GNOMECAT.FileProject.File? file
        {
            get
            {
                return _file;
            }
            set
            {
                _file = value;
                message_list.file = value;
                _file.file_changed.connect(() =>
                    {
                        file_changed(_file);
                    }
                );

                navigator_all = new FileNavigator (this, new TransparentFilter<Message> ());
                navigator_fuzzy = new FileNavigator (this, new FuzzyFilter ());
                navigator_translated = new FileNavigator (this, new TranslatedFilter ());
                navigator_untranslated = new FileNavigator (this, new UntranslatedFilter ());
            }

        }

        public GNOMECAT.UI.ToolBarMode toolbarmode
        {
            get
            {
                return GNOMECAT.UI.ToolBarMode.EDIT;
            }
        }

        public int window_page {get; set;}

        public bool search_enabled
        {
            get
            {
                return searchbar.search_mode_enabled;
            }
            set
            {
                searchbar.search_mode_enabled = value;

                if (value) searchbar.get_focus ();

                if (active_search == null) return;

                if (value) active_search.select ();
                else active_search.deselect ();
            }
        }

        private GNOMECAT.Navigator.FileNavigator navigator_fuzzy;
        private GNOMECAT.Navigator.FileNavigator navigator_translated;
        private GNOMECAT.Navigator.FileNavigator navigator_untranslated;
        private GNOMECAT.Navigator.FileNavigator navigator_all;
        private GNOMECAT.Search.Search active_search;

        public signal void file_changed (GNOMECAT.FileProject.File? file);

        [GtkCallback]
        public void on_message_selected (Message m)
        {
            if (navigator_all != null)
            {
                navigator_all.message = m;
            }

            if (navigator_translated != null)
            {
                if (file.number_of_translated != 0)
                    navigator_translated.message = m;
                else
                    navigator_translated.first ();
            }

            if (navigator_fuzzy != null)
            {
                if (file.number_of_fuzzy != 0)
                    navigator_fuzzy.message = m;
                else
                    navigator_fuzzy.first ();
            }

            if (navigator_untranslated != null)
            {
                if (file.number_of_untranslated != 0)
                    navigator_untranslated.message = m;
                else
                    navigator_untranslated.first ();
            }

            hints_panel.message = m;
            message_editor.message = m;
        }

        [GtkCallback]
        public void on_search_changed (SearchInfo? search_info)
        {
            if (search_info != null)
            {
                active_search.deselect ();
                active_search = new GNOMECAT.Search.Search(this, search_info);
                active_search.next ();
                active_search.select ();
            }
            else
            {
                active_search.deselect();
                active_search = null;
            }
        }

        [GtkCallback]
        public void on_hint_activated (Hint hint)
        {
            string text = hint.translation_hint;
            message_editor.get_active_tab ().translation_text = text;
        }

        public void on_edit_undo (GNOMECAT.UI.Window window)
        {
             MessageEditorTab tab;
             if ((tab = message_editor.get_active_tab ()) != null)
                 tab.undo ();
        }

        public void on_edit_redo (GNOMECAT.UI.Window window)
        {
            MessageEditorTab tab;
            if ((tab = message_editor.get_active_tab ()) != null)
                tab.redo ();
        }

        public void on_go_next (GNOMECAT.UI.Window window)
        {
            navigator_all.next ();
        }

        public void on_go_previous (GNOMECAT.UI.Window window)
        {
            navigator_all.previous ();
        }

        public void on_go_next_fuzzy (GNOMECAT.UI.Window window)
        {
            navigator_fuzzy.next ();
        }

        public void on_go_previous_fuzzy (GNOMECAT.UI.Window window)
        {
            navigator_fuzzy.previous ();
        }

        public void on_go_next_translated (GNOMECAT.UI.Window window)
        {
            navigator_translated.next ();
        }

        public void on_go_previous_translated (GNOMECAT.UI.Window window)
        {
            navigator_translated.previous ();
        }

        public void on_go_next_untranslated (GNOMECAT.UI.Window window)
        {
            navigator_untranslated.next ();
        }

        public void on_go_previous_untranslated (GNOMECAT.UI.Window window)
        {
            navigator_untranslated.previous ();
        }

        public void on_search_next (GNOMECAT.UI.Window window)
        {
            if (active_search != null) active_search.next ();
        }

        public void on_search_previous (GNOMECAT.UI.Window window)
        {
            if (active_search != null) active_search.previous ();
        }

        public void on_search_replace (GNOMECAT.UI.Window window)
        {
            if (active_search != null) active_search.replace ();
        }

        public void on_back (GNOMECAT.UI.Window window)
        {
            window.set_panel (WindowStatus.OPENEDFILES);
        }

        public void on_search (GNOMECAT.UI.Window window)
        {
            search_enabled = ! search_enabled;
        }

        public void on_edit_save (GNOMECAT.UI.Window window)
        {
            if (file.has_changed)
            {
                file.save (null);
            }
        }

        public void on_edit_save_back (GNOMECAT.UI.Window window)
        {
            if (file.has_changed)
            {
                file.save (null);
            }
            else
            {
                on_back (window);
            }
        }

        public void on_change_state (GNOMECAT.UI.Window window)
        {
            Message m = message_editor.message;

            if (m.state == MessageState.TRANSLATED)
                m.state = MessageState.FUZZY;
            else if (m.state == MessageState.FUZZY)
                m.state = MessageState.TRANSLATED;
        }

        public void on_hint (GNOMECAT.UI.Window window, int num)
        {
            hints_panel.activate_row_by_num (num);
        }

        public void select (GNOMECAT.SelectLevel level,
            GNOMECAT.FileProject.MessageFragment? fragment)
        {
            message_list.select (level, fragment);

            if(level != SelectLevel.ROW)
            {
                message_editor.select (level, fragment);
            }
        }

        public void deselect (GNOMECAT.SelectLevel level,
            GNOMECAT.FileProject.MessageFragment? fragment)
        {
            message_list.deselect (level, fragment);

            if(level != SelectLevel.ROW)
            {
                message_editor.deselect (level, fragment);
            }
        }
    }
}