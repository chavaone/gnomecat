/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of valacat
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
 *
 * valacat is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
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
using ValaCAT.FileProject;
using ValaCAT.Languages;

namespace ValaCAT.UI
{
    /**
     * Widget that dislays the strings to be translated.
     *  This widget can be dockable.
     */
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/messagelist.ui")]
    public class MessageListWidget : Gtk.Box
    {
        [GtkChild]
        private ListBox messages_list_box;
        [GtkChild]
        private ScrolledWindow scrolled_window;

        public MessageListRow selected_row {get; private set;}

        public signal void message_selected (Message m);

        private ValaCAT.FileProject.File? _file;
        public ValaCAT.FileProject.File? file
        {
            get
            {
                return _file;
            }
            set
            {
                _file = value;
                foreach (Message m in value.messages)
                    messages_list_box.add (new MessageListRow.with_message (m));
            }
        }

        public MessageListWidget.with_file (ValaCAT.FileProject.File f)
        {
            this ();
            this.file = f;
        }

        public MessageListRow? get_row_by_message (Message m)
        {
            foreach (Widget w in this.messages_list_box.get_children ())
            {
                ValaCAT.UI.MessageListRow row = w as ValaCAT.UI.MessageListRow;

                if (row.message == m)
                {
                    return row;
                }
            }
            return null;
        }

        public void select_row (MessageListRow row)
        {
            messages_list_box.select_row (row);
        }

        public void select_editor_tab (int plural_number)
        {
            if (selected_row != null)
                selected_row.select_tab_by_plural_number (plural_number);
        }

        public MessageEditorTab? get_tab_by_plural_number (int plural_number)
        {
            return selected_row == null ? null :
                selected_row.get_tab_by_plural_number (plural_number);
        }

        public MessageEditorTab? get_active_editor_tab ()
        {
            return selected_row == null ? null :
                selected_row.get_active_tab ();
        }

        [GtkCallback]
        private void on_row_selected (Gtk.ListBox src, Gtk.ListBoxRow row)
        {
            selected_row.edition_mode = false;
            selected_row = (row as MessageListRow);
            selected_row.edition_mode = true;
            message_selected (selected_row.message);
        }
    }

    /**
     *
     */
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/messagelistrow.ui")]
    public class MessageListRow : ListBoxRow
    {

        [GtkChild]
        private Image state_image;
        [GtkChild]
        private Gtk.Entry original;
        [GtkChild]
        private Gtk.Entry translation;
        [GtkChild]
        private Image info_image;
        [GtkChild]
        private Image warning_image;
        [GtkChild]
        private Image error_image;
        [GtkChild]
        private Gtk.Box info_box;
        [GtkChild]
        private Gtk.Notebook editor_notebook;


        private Message _message;
        public Message message
        {
            get
            {
                return _message;
            }
            set
            {
                _message = value;
                value.message_changed.connect (set_info_box_properties);
                set_info_box_properties ();
            }
        }

        public bool edition_mode
        {
            get
            {
                return editor_notebook.visible;
            }
            set
            {
                editor_notebook.visible = value;
                info_box.visible = ! value;
                if (value)
                    set_editor_box_properties ();
                else
                    clean_tabs ();
            }
        }

        public MessageListRow.with_message (Message m)
        {
            message = m;
        }

        public MessageEditorTab? get_active_tab ()
        {
            int curr_page = editor_notebook.get_current_page ();
            return editor_notebook.get_nth_page (curr_page) as MessageEditorTab;
        }

        public MessageEditorTab? get_tab_by_plural_number (int plural_number)
        {
            if (plural_number > editor_notebook.get_n_pages ())
                return null;

            return editor_notebook.get_nth_page (plural_number) as MessageEditorTab;
        }

        public void select_tab_by_plural_number (int plural_number)
        {
            if (plural_number > editor_notebook.get_n_pages ())
                return;
            editor_notebook.set_current_page (plural_number);
        }

        private void add_tab (MessageEditorTab t)
        {
            editor_notebook.append_page (t, t.label);
        }

        private void clean_tabs ()
        {
            int number_of_tabs = this.editor_notebook.get_n_pages ();
            for (int i=0; i<number_of_tabs; i++)
            {
                this.editor_notebook.remove_page (0);
            }
        }

        private void set_editor_box_properties ()
        {
            int i;
            clean_tabs ();
            PluralForm enabled_plural_form = ValaCAT.Application.get_default ().enabled_profile.plural_form;

            string label = _("Singular (%s)").printf (enabled_plural_form.plural_tags.get (0));
            add_tab (new MessageEditorTab (label, message, 0));

            if (message.has_plural ())
            {
                int num_plurals = enabled_plural_form.number_of_plurals;

                for (i = 1; i < num_plurals; i++)
                {
                    label = _("Plural %i (%s)").printf (i, enabled_plural_form.plural_tags.get (i));
                    add_tab (new MessageEditorTab (label, message, i));
                }
            }
        }

        private void set_info_box_properties ()
        {
            string status_icon_name = "";
            string status_tooltip_text = "";
            int number_info_tips = 0, number_warning_tips = 0, number_error_tips = 0;

            switch (this.message.state)
            {
            case MessageState.TRANSLATED:
                status_icon_name = "emblem-default-symbolic";
                status_tooltip_text = _("Translated");
                break;
            case MessageState.UNTRANSLATED:
                status_icon_name = "window-close-symbolic";
                status_tooltip_text = _("Untraslated");
                break;
            case MessageState.FUZZY:
                status_icon_name = "dialog-question-symbolic";
                status_tooltip_text = _("Fuzzy");
                break;
            }

            this.state_image.icon_name = status_icon_name;
            this.state_image.tooltip_text = status_tooltip_text;

            this.original.set_text (this.message.get_original_singular ());
            if (this.message.get_translation (0) != null)
                this.translation.set_text (this.message.get_translation (0));

            foreach (MessageTip t in this.message.tips)
            {
                switch (t.level)
                {
                case TipLevel.INFO:
                    number_info_tips++;
                    break;
                case TipLevel.ERROR:
                    number_error_tips++;
                    break;
                case TipLevel.WARNING:
                    number_warning_tips++;
                    break;
                }
            }

            if (number_info_tips > 0)
            {
                this.info_image.visible = true;
                this.info_image.tooltip_text = ngettext ("There is %i info tip",
                    "There are %i info tips.",number_info_tips).printf (number_info_tips);
            }

            if (number_warning_tips > 0)
            {
                this.warning_image.visible = true;
                this.warning_image.tooltip_text = ngettext ("Ther is %i warning tip.",
                    "There are %i warning tips.", number_warning_tips).printf (number_warning_tips);
            }

            if (number_error_tips > 0)
            {
                this.error_image.visible = true;
                this.error_image.tooltip_text = ngettext ("There is %i error tip.",
                    "There are %i error tips.", number_error_tips).printf (number_error_tips);
            }
        }

        [GtkCallback]
        private void on_page_added (Gtk.Widget pate, uint page_num)
        {
            if (editor_notebook.get_n_pages () > 1)
                editor_notebook.show_tabs = true;
        }

        [GtkCallback]
        private void on_page_removed (Gtk.Widget pate, uint page_num)
        {
            if (editor_notebook.get_n_pages () <= 1)
                editor_notebook.show_tabs = false;
        }
    }
}
