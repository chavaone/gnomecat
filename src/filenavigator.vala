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
    public class FileNavigator : Navigator, ChangedMessageSensible
    {
        private GNOMECAT.File file;
        private FileIterator iterator;
        private IteratorFilter<Message> filter;
        private GNOMECAT.UI.EditPanel edit_panel;

        private Message _message;
        public Message message
        {
            get
            {
                _message = iterator.current;
                return _message;
            }
            set
            {
                if (filter.check (value))
                {
                    _message = value;
                }
                else
                {
                    int index;

                    for (index = file.messages.index_of (value);
                        index >= 0 && ! filter.check (file.messages.get (index));
                        index--);

                    if (index == -1)
                    {
                        _message = iterator.first ();
                    }
                    else
                    {
                        _message = file.messages.get (index);
                    }
                }

                for (Message? current_message = iterator.first ();
                    current_message != _message && current_message != null;
                    current_message = iterator.next ());
            }
        }

        public FileNavigator (GNOMECAT.UI.EditPanel edit_panel,
            IteratorFilter<Message> filter)
        {
            this.edit_panel = edit_panel;
            this.file = edit_panel.file;
            this.filter = filter;
            iterator = new FileIterator (file, filter);
        }

        public override bool next ()
        {
            if (iterator.next () == null)
                return false;

            select_current ();
            return true;
        }

        public override bool previous ()
        {
            if (iterator.previous () == null)
                return false;

            select_current ();
            return true;
        }

        public override bool first ()
        {
            if (iterator.first () == null)
                return false;

            select_current ();
            return true;
        }

        public override bool last ()
        {
            if (iterator.last () == null)
                return false;

            select_current ();
            return true;
        }

        private void select_current ()
        {
            Message? m = iterator.current;
            if (m != null)
                edit_panel.select (SelectLevel.ROW,
                    new MessageFragment (m, 0, false, 0, 0));
        }
    }
}