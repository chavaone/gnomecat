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


using Gee;
using GNOMECAT.Iterators;
using GNOMECAT.UI;

namespace GNOMECAT.Navigator
{
    public class FileNavigator : Navigator
    {

        private CheckMessageFunction check_function;
        private GNOMECAT.UI.MessageListWidget msg_list;

        public FileNavigator (GNOMECAT.UI.EditPanel edit_panel,
            CheckMessageFunction check_function)
        {
            this.msg_list = edit_panel.message_list;
            this.check_function = check_function;
        }

        public override bool next ()
        {
            Gtk.ListBox list = msg_list.messages_list_box;
            Gtk.ListBoxRow? sr = list.get_selected_row ();
            int selected_index = sr == null ? -1 : sr.get_index ();
            GLib.List<unowned Gtk.Widget> rows = list.get_children ();

            for (uint i = selected_index + 1; i < rows.length (); i++)
            {
                GNOMECAT.UI.MessageListRow row = rows.nth_data (i) as GNOMECAT.UI.MessageListRow;
                if (check_function (row.message))
                {
                    msg_list.select_row (row);
                    return true;
                }
            }
            return false;
        }

        public override bool previous ()
        {
            Gtk.ListBox list = msg_list.messages_list_box;
            Gtk.ListBoxRow? sr = list.get_selected_row ();
            int selected_index = sr == null ? 1 : sr.get_index ();
            GLib.List<unowned Gtk.Widget> rows = list.get_children ();

            for (uint i = selected_index - 1; i >= 0; i--)
            {
                GNOMECAT.UI.MessageListRow row = rows.nth_data (i) as GNOMECAT.UI.MessageListRow;
                if (check_function (row.message))
                {
                    msg_list.select_row (row);
                    return true;
                }
            }
            return false;
        }

        public override bool first ()
        {
            Gtk.ListBox list = msg_list.messages_list_box;
            GLib.List<unowned Gtk.Widget> rows = list.get_children ();

            for (uint i = 0; i < rows.length (); i++)
            {
                GNOMECAT.UI.MessageListRow row = rows.nth_data (i) as GNOMECAT.UI.MessageListRow;
                if (check_function (row.message))
                {
                    msg_list.select_row (row);
                    return true;
                }
            }
            return false;
        }

        public override bool last ()
        {
            Gtk.ListBox list = msg_list.messages_list_box;
            GLib.List<unowned Gtk.Widget> rows = list.get_children ();

            for (uint i = rows.length () - 1; i > 0; i--)
            {
                GNOMECAT.UI.MessageListRow row = rows.nth_data (i) as GNOMECAT.UI.MessageListRow;
                if (check_function (row.message))
                {
                    msg_list.select_row (row);
                    return true;
                }
            }
            return false;
        }
    }
}