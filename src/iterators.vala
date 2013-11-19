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

using Gee;
using ValaCAT.FileProject;
using ValaCAT.Languages;

namespace ValaCAT.Iterators
{
    /**
     *
     */
    public abstract class IteratorFilter<E> : Object
    {
        /**
         * Method that checks if an element is valid.
         */
        public abstract bool check (E element);
    }


    /**
     * Filter for translated messages.
     */
    public class TranslatedFilter : IteratorFilter<Message>
    {
        public override bool check (Message element)
        {
            return element.state == MessageState.TRANSLATED;
        }
    }


    /**
     * Filter for untranslated messages.
     */
    public class UntranslatedFilter : IteratorFilter<Message>
    {
        public override bool check (Message element)
        {
            return element.state == MessageState.UNTRANSLATED;
        }
    }


    /**
     * Filter for fuzzy messages.
     */
    public class FuzzyFilter : IteratorFilter<Message>
    {
        public override bool check (Message element)
        {
            return element.state == MessageState.FUZZY;
        }
    }


    /**
     * Filter that combines several filters accepting
     *  the elements that accomplish the conditions of
     *  one of the provided filters.
     */
    public class ORFilter<R> : IteratorFilter<R>
    {

        public ArrayList<IteratorFilter<R>> filters {get; private set;}

        public ORFilter (ArrayList<IteratorFilter<R>> filters)
        {
            this.filters = filters;
        }

        public override bool check (R m)
        {
            foreach (IteratorFilter<R> mf in filters)
                if (mf.check (m))
                    return true;
            return false;
        }
    }


    /**
     * Filter for the original text of the message.
     */
    public class OriginalFilter : IteratorFilter<MessageFragment>
    {
        public override bool check (MessageFragment mm)
        {
            return mm.is_original;
        }
    }


    /**
     * Filter for the translation text of the message.
     */
    public class TranslationFilter : IteratorFilter<MessageFragment>
    {
        public override bool check (MessageFragment mm)
        {
            return ! mm.is_original;
        }
    }


    /**
     * Filter that accepts all parts from the message.
     */
    public class AllMessageFragmentFilter : IteratorFilter<MessageFragment>
    {
        public override bool check (MessageFragment mm)
        {
            return true;
        }
    }


    /**
     * Generic class for iterators. It iterates over
     *  a element \\Ele\\ and returns instances of \\Ret\\.
     */
    public abstract class Iterator<Ele, Ret> : Object
    {
        public abstract Ret  next ();
        public abstract Ret  previous ();
        public abstract Ret  get_current_element ();
        public abstract void last ();
        public abstract void first ();
        public abstract bool is_last ();
        public abstract void set_element (Ele element);
    }


    /**
     *
     */
    public class FileIterator : Iterator<ValaCAT.FileProject.File?, Message?>
    {
        public ValaCAT.FileProject.File file {get; private set;}
        public IteratorFilter<Message> filter {get; private set;}


        private int current_index;
        private bool visited;
        private ArrayList<Message> messages;


        public FileIterator (ValaCAT.FileProject.File? f, IteratorFilter<Message> mf)
        {
            this.set_element (f);
            this.filter = mf;
        }


        public override void set_element (ValaCAT.FileProject.File? f)
        {
            this.file = f;
            this.messages = f == null ? null : f.messages;
            this.first ();
        }


        public override Message? next ()
        {
            if ((visited || ! check_condition (messages.get (current_index)))
                && current_index <= messages.size)
            {
                for (current_index++;
                    current_index < messages.size &&
                        ! check_condition (messages.get (current_index));
                    current_index++);
            }

            this.visited = true;
            return this.get_current_element ();
        }


        public override Message? previous ()
        {
            if ((visited || ! check_condition (messages.get (current_index)))
                && current_index > -1 )
            {
                for (current_index--;
                    current_index >= 0 &&
                       ! check_condition (this.messages.get (current_index));
                    current_index--);
            }

            this.visited = true;
            return this.get_current_element ();
        }


        public override void first ()
        {
            this.current_index = 0;
            this.visited = false;
        }

        public override void last ()
        {
            this.current_index = this.messages.size - 1;
            this.visited = false;
        }

        public override bool is_last ()
        {
            return this.current_index == this.messages.size -1;
        }

        public override Message? get_current_element ()
        {
            if (this.messages == null || this.current_index < 0 ||
                this.current_index >= this.messages.size)
                return null;
            if (! visited)
                return next ();
            return this.messages.get (this.current_index);
        }

        private bool check_condition (Message m)
        {
            return  this.filter != null && this.filter.check (m);
        }
    }


    /**
     *
     */
    public class MessageIterator : Iterator<Message?, MessageFragment?>
    {
        public Message message {get; private set;}
        public string search_string {get; private set;}

        private ArrayList<MessageFragment> marks;
        private int marks_index;
        private IteratorFilter<MessageFragment> filter;
        private bool visited;

        public MessageIterator (Message? msg, string search_string,
            IteratorFilter<MessageFragment> filter)
        {
            this.search_string = search_string;
            this.filter = filter;
            this.marks = new ArrayList<MessageFragment> ();
            if (msg != null)
                this.set_element (msg);
        }

        public override MessageFragment? next ()
        {
            if (! this.visited)
                this.visited = true;
            else if (marks_index != this.marks.size)
                marks_index++;

            return this.get_current_element ();
        }

        public override MessageFragment? previous ()
        {
            if (! this.visited)
                this.visited = true;
            else if (marks_index != -1)
                marks_index--;

            return this.get_current_element ();
        }

        public override void first ()
        {
            marks_index = 0;
            this.visited = false;
        }

        public override void last ()
        {
            marks_index = this.marks.size - 1;
            this.visited = false;
        }

        public override bool is_last ()
        {
            return marks_index == marks.size - 1;
        }

        public override MessageFragment? get_current_element ()
        {
            if (this.marks == null || marks_index < 0 ||
                marks_index >= this.marks.size)
                return null;
            return this.marks.get (marks_index);
        }

        public override void set_element (Message? element)
        {
            this.message = element;
            this.marks.clear ();
            if (element != null)
                this.get_marks ();
            this.first ();
        }

        private void get_marks ()
        {
            int index;
            MessageFragment mm;

            for (index = message.get_original_singular ().index_of (this.search_string);
                index != -1;
                index = this.message.get_original_singular ().index_of (this.search_string, ++index))
            {
                mm = new MessageFragment (this.message, 0, true, index, this.search_string.char_count ());
                if (this.check_mark (mm))
                    this.marks.add (mm);
            }

            index = 0;
            if (this.message.get_translation (0) != null)
                while ((index = this.message.get_translation (0).index_of (this.search_string, index)) != -1)
                {
                    mm = new MessageFragment (this.message, 0, false, index, this.search_string.char_count ());
                    if (this.check_mark (mm))
                        this.marks.add (mm);
                    index++;
                }

            if (this.message.has_plural ())
            {
                index = 0;
                while ((index = this.message.get_original_plural ().index_of (this.search_string, index)) != -1)
                {
                    mm = new MessageFragment (this.message, 1, true, index, this.search_string.char_count ());
                    if (this.check_mark (mm))
                        this.marks.add (mm);
                    index++;
                }
                PluralForm enabled_plural_form = ValaCAT.Application.get_default ().enabled_profile.plural_form;
                for (int plural_number = 1; plural_number < enabled_plural_form.number_of_plurals; plural_number++)
                {
                    index = 0;
                    string message_string = this.message.get_translation (plural_number);
                    if (message_string != null)
                    {
                        while ((index = message_string.index_of (this.search_string, index)) != -1)
                        {
                            mm = new MessageFragment (this.message, plural_number, false, index, this.search_string.char_count ());
                            if (this.check_mark (mm))
                                this.marks.add (mm);
                            index++;
                        }
                    }
                }
            }
        }

        private bool check_mark (MessageFragment mm)
        {
            return this.filter == null ? false :
                this.filter.check (mm);
        }
    }
}