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

using ValaCAT.FileProject;
using Gee;
using ValaCAT.Iterators;
using ValaCAT.UI;

namespace ValaCAT.Navigator
{
    public class Navigator : Object, ChangedMessageSensible
    {
        private ValaCAT.FileProject.File file;
        private FileIterator iterator;
        private IteratorFilter<Message> filter;

        private Message _message;
        public Message message
        {
            get
            {
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

        public Navigator (ValaCAT.FileProject.File file, IteratorFilter<Message> filter)
        {
            this.file = file;
            this.filter = filter;
            iterator = new FileIterator (file, filter);
        }

        public void next_item ()
        {
            Message? m = iterator.next ();

            if (m == null)
                return;

            ValaCAT.Application.get_default ().select (SelectLevel.ROW,
                new MessageFragment (m, 0, false, 0, 0));
        }

        public void previous_item ()
        {
            Message? m = iterator.previous ();

            if (m == null)
                return; //FIXME

            ValaCAT.Application.get_default ().select (SelectLevel.ROW,
                new MessageFragment (m, 0, false, 0, 0));
        }
    }
}