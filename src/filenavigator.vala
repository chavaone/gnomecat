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

using GNOMECAT.FileProject;
using Gee;
using GNOMECAT.Iterators;
using GNOMECAT.UI;

namespace GNOMECAT.Navigator
{
    public class FileNavigator : Navigator, ChangedMessageSensible
    {
        private GNOMECAT.FileProject.File file;
        private FileIterator iterator;
        private IteratorFilter<Message> filter;

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
                    Gee.ArrayList<Message> msgs = file.messages;
                    int index;
                    for (index = msgs.index_of (value);
                        index >= 0 && ! filter.check (msgs.get (index));
                        index--);

                    if (index == -1)
                    {
                        _message = iterator.first ();
                    }
                    else
                    {
                        _message = msgs.get (index);
                    }
                }

                for (Message? current_message = iterator.first ();
                    current_message != _message && current_message != null;
                    current_message = iterator.next ());
            }
        }

        public FileNavigator (GNOMECAT.FileProject.File file,
            IteratorFilter<Message> filter)
        {
            this.file = file;
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
                GNOMECAT.Application.get_default ().select (SelectLevel.ROW,
                    new MessageFragment (m, 0, false, 0, 0));
        }
    }
}