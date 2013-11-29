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
using Gee;
using GNOMECAT.FileProject;
using GNOMECAT.Iterators;
using GNOMECAT.Search;
using GNOMECAT.UI;

namespace GNOMECAT.Search
{
    public abstract class Search : GNOMECAT.Navigator.Navigator
    {
        public abstract string search_text {get; set;}

        public abstract string replace_text {get; set;}

        public abstract void replace ();

        public abstract void select ();

        public abstract void deselect ();
    }


    /*
    public class ProjectSearch : Search
    {
    }
    */

    public class FileSearch : Search
    {

        public override string replace_text {get; private set;}
        public override string search_text {get; private set;}

        private FileIterator file_iterator;
        private MessageIterator message_iterator;
        private IteratorFilter<MessageFragment> filter_marks;

        public FileSearch (GNOMECAT.FileProject.File file,
            bool translated, bool untranslated, bool fuzzy,
            bool original, bool translation, string search_text,
            string replace_text)
        {

            this.replace_text = replace_text;
            this.search_text = search_text;

            file_iterator = new FileIterator (file, get_message_filter(translated,
                untranslated, fuzzy));

            filter_marks = get_fragments_filter (original, translation);
            message_iterator = new MessageIterator (file_iterator.current,
                search_text, filter_marks);
        }

        private IteratorFilter<Message>? get_message_filter (bool translated,
            bool untranslated, bool fuzzy)
        {
            ArrayList<IteratorFilter<Message>> filters_file
                = new ArrayList<IteratorFilter<Message>> ();
            if (translated)
                filters_file.add (new TranslatedFilter ());

            if (untranslated)
                filters_file.add (new UntranslatedFilter ());

            if (fuzzy)
                filters_file.add (new FuzzyFilter ());

            if (filters_file.size == 0)
                return null;
            else if (filters_file.size == 1)
                return filters_file.get (0);
            else
                return new ORFilter<Message> (filters_file);
        }

        private IteratorFilter<MessageFragment>? get_fragments_filter (bool original,
            bool translation)
        {
            ArrayList<IteratorFilter<MessageFragment>> filters_mark_array
                = new ArrayList<IteratorFilter<MessageFragment>> ();
            if (original)
                filters_mark_array.add (new OriginalFilter ());

            if (translation)
                filters_mark_array.add (new TranslationFilter ());

            if (filters_mark_array.size == 0)
                return null;
            else if (filters_mark_array.size == 1)
                return filters_mark_array.get (0);
            else
                return new ORFilter<MessageFragment> (filters_mark_array);
        }

        public override bool next ()
        {
            deselect ();

            MessageFragment mf = message_iterator.next ();

            while (mf == null)
            {
                Message msg = file_iterator.next ();
                if (msg == null) return false;

                message_iterator = new MessageIterator (msg, search_text, filter_marks);
                mf = message_iterator.current;
            }

            GNOMECAT.Application.get_default ().select (SelectLevel.STRING, mf);
            return true;
        }

        public override bool previous ()
        {
            deselect ();

            MessageFragment mf = message_iterator.previous ();

            while (mf == null)
            {
                Message msg = file_iterator.previous ();
                if (msg == null) return false;

                message_iterator = new MessageIterator (msg, search_text, filter_marks);
                mf = message_iterator.current;
            }

            GNOMECAT.Application.get_default ().select (SelectLevel.STRING, mf);
            return true;
        }

        public override bool first ()
        {
            deselect ();

            Message msg = file_iterator.first ();
            if (msg == null) return false;

            message_iterator = new MessageIterator (msg, search_text, filter_marks);
            MessageFragment mf = message_iterator.first ();
            if (mf == null) return next ();

            GNOMECAT.Application.get_default ().select (SelectLevel.STRING, mf);
            return true;
        }

        public override bool last ()
        {
            deselect ();

            Message msg = file_iterator.last ();
            if (msg == null) return false;

            message_iterator = new MessageIterator (msg, search_text, filter_marks);
            MessageFragment mf = message_iterator.last ();
            if (mf == null) return previous ();

            GNOMECAT.Application.get_default ().select (SelectLevel.STRING, mf);
            return true;
        }

        public override void replace ()
        {
            MessageFragment? mf = message_iterator.current;

            if (mf == null || mf.is_original)
                return;

            string original_string = mf.message.get_translation (mf.plural_number);
            mf.message.set_translation (mf.plural_number,
                original_string.substring (0, mf.index) +
                this.replace_text +
                original_string.substring (mf.index + mf.length));
        }

        public override void select ()
        {
            MessageFragment mf = message_iterator.current;
            if (mf != null)
                GNOMECAT.Application.get_default ().select (SelectLevel.STRING, mf);
        }

        public override void deselect ()
        {
            MessageFragment mf = message_iterator.current;
            if (mf != null)
                GNOMECAT.Application.get_default ().deselect (SelectLevel.STRING, mf);
        }
    }
}