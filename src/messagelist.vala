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
using GNOMECAT.FileProject;
using GNOMECAT.Languages;

namespace GNOMECAT.UI
{
    /**
     * Widget that dislays the strings to be translated.
     *  This widget can be dockable.
     */
    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/messagelist.ui")]
    public class MessageListWidget : Gtk.Box
    {
        [GtkChild]
        private ListBox messages_list_box;
        [GtkChild]
        private ScrolledWindow scrolled_window;

        public MessageListRow selected_row {get; private set;}

        public signal void message_selected (Message m);

        private GNOMECAT.FileProject.File? _file;
        public GNOMECAT.FileProject.File? file
        {
            get
            {
                return _file;
            }
            set
            {
                _file = value;
                clean_messages ();
                foreach (Message m in value.messages)
                    messages_list_box.add (new MessageListRow.with_message (m));

                Gtk.ListBoxRow row = messages_list_box.get_row_at_index (0);
                messages_list_box.select_row (row);
            }
        }

        public MessageListWidget.with_file (GNOMECAT.FileProject.File f)
        {
            this ();
            this.file = f;
        }

        public void select (GNOMECAT.SelectLevel level,
            GNOMECAT.FileProject.MessageFragment? fragment)
        {
            assert (fragment != null && fragment.message != null);

            MessageListRow row = get_row_by_message(fragment.message);
            if (row == null)
                return;

            messages_list_box.select_row (row);
        }

        public void deselect (GNOMECAT.SelectLevel level,
            GNOMECAT.FileProject.MessageFragment? fragment)
        {
            assert (fragment != null && fragment.message != null);

            MessageListRow row = get_row_by_message(fragment.message);
            if (row == null)
                return;
        }

        public MessageListRow? get_row_by_message (Message m)
        {
            foreach (Widget w in this.messages_list_box.get_children ())
            {
                GNOMECAT.UI.MessageListRow row = w as GNOMECAT.UI.MessageListRow;

                if (row.message == m)
                {
                    return row;
                }
            }
            return null;
        }

        [GtkCallback]
        private void on_row_selected (Gtk.ListBoxRow? row)
        {
            if (selected_row == row)
                return;

            selected_row = (row as MessageListRow);
            message_selected (selected_row.message);
        }

        private void clean_messages ()
        {
            foreach (Widget w in messages_list_box.get_children ())
            {
                messages_list_box.remove (w);
            }
        }
    }

    /**
     *
     */
    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/messagelistrow.ui")]
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

        public MessageListRow.with_message (Message m)
        {
            message = m;
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
                status_tooltip_text = _("Untranslated");
                break;
            case MessageState.FUZZY:
                status_icon_name = "dialog-question-symbolic";
                status_tooltip_text = _("Fuzzy");
                break;
            }

            this.state_image.icon_name = status_icon_name;
            this.state_image.tooltip_text = status_tooltip_text;

            if (message.get_original_singular () != null)
            {
                original.set_text (message.get_original_singular ());
            }

            if (message.get_translation (0) != null)
            {
                translation.set_text (message.get_translation (0));
            }

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
       private bool on_clicked (Gdk.EventButton e)
       {
            (get_parent() as ListBox).row_selected (this);
            return false;
       }

       [GtkCallback]
       private void on_entry_selected ()
       {
            (get_parent() as ListBox).row_selected (this);
       }
    }
}
