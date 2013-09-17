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
using Gdl;
using ValaCAT.FileProject;

namespace ValaCAT.UI
{
    /**
     * Widget that dislays the strings to be translated.
     *  This widget can be dockable.
     */
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/messagelist.ui")]
    public class MessageListWidget : DockItem
    {
        [GtkChild]
        private ListBox messages_list_box;

        public signal void message_selected (Message m);

        public MessageListWidget (ValaCAT.FileProject.File f)
        {
            foreach (Message m in f.messages)
            {
                this.add_message (m);
            }
        }

        private void add_message (Message m)
        {
            this.messages_list_box.add (new MessageListRow (m));
        }

        public MessageListRow? find_row_by_message (Message m)
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
            this.messages_list_box.select_row (row);
        }

        [GtkCallback]
        private void on_row_selected (Gtk.ListBox src, Gtk.ListBoxRow row)
        {
            this.message_selected ((row as MessageListRow).message);
        }
    }

    /**
     *
     */
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/messagelistrow.ui")]
    public class MessageListRow : ListBoxRow
    {

        /**
         * Message related with this row.
         */
        public Message message {get; private set;}

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


        /**
         *
         */
        public MessageListRow (Message m)
        {
            this.message = m;
            m.message_changed.connect (update_row);
            this.update_row ();
        }


        private void update_row ()
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
    }
}
