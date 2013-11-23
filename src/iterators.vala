/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of GnomeCAT
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
 *
 * GnomeCAT is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * GnomeCAT is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with GnomeCAT. If not, see <http://www.gnu.org/licenses/>.
 */

using Gee;
using GnomeCAT.FileProject;
using GnomeCAT.Languages;

namespace GnomeCAT.Iterators
{
    public abstract class Iterator<Element> : Object
    {
        /**
         * The current element of the iterator if any.
         */
        public abstract Element current {get;}

        /**
         * Returns the previous element. If the current
         *  element is the first then it returns null.
         */
        public abstract Element previous ();

        /**
         * Returns the next element. If the current
         *  element is the last then it returns null.
         */
        public abstract Element next ();

        /**
         * Returns the first element if any.
         */
        public abstract Element first ();

        /**
         * Returns the last element if any.
         */
        public abstract Element last ();

        /**
         * Returns a value that allows to
         *  know if the current element is
         *  the first. If there is no elements
         *  then it returns false.
         */
        public abstract bool is_first ();

        /**
         * Returns a value that allows to
         *  know if the current element is
         *  the last. If there is no elements
         *  then it returns false.
         */
        public abstract bool is_last ();
    }


    public class FileIterator : Iterator<Message?>
    {
        private GnomeCAT.FileProject.File _file;
        public GnomeCAT.FileProject.File file
        {
            get
            {
                return _file;
            }
            private set
            {
                _file = value;
                messages = _file == null ? null : _file.messages;
                current_index = 0;
            }
        }

        public IteratorFilter<Message> filter {get; private set;}

        private int current_index;
        private ArrayList<Message> messages;

        private Message? _current;
        public override Message? current
        {
            get
            {
                if (messages == null || current_index >= messages.size
                    || current_index < 0)
                    return null;

                _current = messages.get (current_index);
                return _current;
            }
        }

        public FileIterator (GnomeCAT.FileProject.File? f,
            IteratorFilter<Message> mf)
        {
            file = f;
            filter = mf;
        }

        public override Message? previous ()
        {
            if (messages == null || is_first ())
                return null;

            do current_index--;
            while (!check_condition (current) && ! is_first ());

            if (is_first () && !check_condition (current))
                return null;

            return current;
        }

        public override Message? next ()
        {
            if (messages == null || is_last ())
                return null;

            do current_index++;
            while (!check_condition (current) && ! is_last ());

            if (is_last () && !check_condition (current))
                return null;

            return current;
        }

        public override Message? first ()
        {
            if (messages == null)
                return null;

            current_index = 0;

            if (check_condition (current))
                return current;
            else
                return next ();
        }

        public override Message? last ()
        {
            if (messages == null)
                return null;

            current_index = messages.size - 1;

            if (check_condition (current))
                return current;
            else
                return previous ();
        }

        public override bool is_first ()
        {
            int aux_index = current_index;

            if (messages == null || messages.size == 0)
                return false;

            if (aux_index == 0)
                return true;

            for(aux_index--; aux_index >= 0; aux_index--)
                if (check_condition (messages.get(aux_index)))
                    return false;
            return true;
        }

        public override bool is_last ()
        {
            int aux_index = current_index;

            if (messages == null || messages.size == 0)
                return false;

            if (aux_index == messages.size - 1)
                return true;

            for(aux_index++; aux_index < messages.size; aux_index++)
                if (check_condition (messages.get(aux_index)))
                    return false;
            return false;
        }

        private bool check_condition (Message m)
        {
            return  this.filter != null && this.filter.check (m);
        }
    }


    public class MessageIterator : Iterator<MessageFragment?>
    {
        public Message message {get; private set;}

        private int current_index;
        private ArrayList<MessageFragment> message_fragments;

        private MessageFragment? _current;
        public override MessageFragment? current
        {
            get
            {
                if (message_fragments == null || current_index < 0
                    || current_index >= message_fragments.size)
                    return null;
                _current = message_fragments.get (current_index);
                return _current;
            }
        }

        public MessageIterator (Message msg, string search_string,
            IteratorFilter<MessageFragment> filter)
        {
            message = msg;
            get_message_fragments (msg, search_string, filter);
            current_index = 0;
        }

        public override MessageFragment? previous ()
        {
            current_index--;
            return current;
        }

        public override MessageFragment? next ()
        {
            current_index++;
            return current;
        }

        public override MessageFragment? first ()
        {
            current_index = 0;
            return current;
        }

        public override MessageFragment? last ()
        {
            current_index = message_fragments.size - 1;
            return current;
        }

        public override bool is_first ()
        {
            if (message_fragments.size == 0)
                return false;

            return current_index == 0;
        }

        public override bool is_last ()
        {
            if (message_fragments.size == 0)
                return false;

            return current_index == message_fragments.size - 1;
        }

        private void get_message_fragments (Message message, string search_string,
            IteratorFilter<MessageFragment> filter)
        {

            message_fragments = new ArrayList<MessageFragment> ();

            message_fragments.add_all (get_fragments_from_string (message,
                message.get_original_singular (), search_string,
                filter, 0, true));

            message_fragments.add_all (get_fragments_from_string (message,
                message.get_translation (0), search_string,
                filter, 0, false));

            if (message.has_plural ())
            {
                message_fragments.add_all (get_fragments_from_string (message,
                        message.get_original_plural (), search_string,
                        filter, 1, true));

                PluralForm plural_form = GnomeCAT.Application
                    .get_default ().enabled_profile.plural_form;
                for (int plural_number = 1;
                    plural_number < plural_form.number_of_plurals;
                    plural_number++)
                {
                    message_fragments.add_all (get_fragments_from_string (message,
                        message.get_translation (plural_number), search_string,
                        filter, plural_number, false));
                }
            }
        }

        private ArrayList<MessageFragment> get_fragments_from_string (
            Message message, string message_string, string search_string,
            IteratorFilter<MessageFragment> filter, int plural_number,
            bool original)
        {
            int index = 0;
            MessageFragment mm;
            ArrayList<MessageFragment> ret_arr = new ArrayList<MessageFragment> ();

            if (message_string == null)
                return ret_arr;

            while ((index = message_string.index_of (search_string, index)) != -1)
            {
                mm = new MessageFragment (message, plural_number,
                    original, index, search_string.char_count ());

                if (check_mark (mm, filter))
                    ret_arr.add (mm);
                index++;
            }
            return ret_arr;
        }

        private bool check_mark (MessageFragment mm,
            IteratorFilter<MessageFragment> filter)
        {
            return filter != null && filter.check (mm);
        }
    }
}