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

 namespace GNOMECAT.Search
 {

    public class SearchInfo : Object {
        public string replace_text {get; private set;}
        public string search_text {get; private set;}
        public bool translated {get; private set;}
        public bool untranslated {get; private set;}
        public bool fuzzy {get; private set;}
        public bool original {get; private set;}
        public bool translation {get; private set;}
        public bool plurals {get; private set;}


        public SearchInfo (bool translated, bool untranslated, bool fuzzy,
            bool original, bool translation, bool plurals, string search_text,
            string replace_text)
        {
            this.translated = translated;
            this.untranslated = untranslated;
            this.fuzzy = fuzzy;
            this.original = original;
            this.translation = translation;
            this.plurals = plurals;
            this.replace_text = replace_text;
            this.search_text = search_text;
        }
    }

    public class Search : GNOMECAT.Navigator.Navigator
    {

        private SearchInfo search_info;
        private GNOMECAT.UI.EditPanel edit_panel;

        private FileIterator file_iterator;
        private MessageIterator message_iterator;
        private IteratorFilter<MessageFragment> filter_marks;


        private GNOMECAT.FileProject.File _file;
        public GNOMECAT.FileProject.File file {
            get {
                return _file;
            }
            set {

                assert(value == edit_panel.file);

                file_iterator = new FileIterator (value,
                    get_message_filter(search_info.translated,
                        search_info.untranslated, search_info.fuzzy));

                filter_marks = get_fragments_filter (search_info.original,
                    search_info.translation);
                message_iterator = new MessageIterator (file_iterator.current,
                    search_info.search_text, filter_marks);
            }
        }


        public Search (GNOMECAT.UI.EditPanel edit_panel, SearchInfo search_info)
        {
            this.search_info = search_info;
            this.edit_panel = edit_panel;
            if (edit_panel.file != null)
            {
                this.file = edit_panel.file;
            }
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

                message_iterator = new MessageIterator (msg, search_info.search_text, filter_marks);
                mf = message_iterator.current;
            }

            edit_panel.select (SelectLevel.STRING, mf);
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

                message_iterator = new MessageIterator (msg, search_info.search_text, filter_marks);
                mf = message_iterator.current;
            }

            edit_panel.select (SelectLevel.STRING, mf);
            return true;
        }

        public override bool first ()
        {
            deselect ();

            Message msg = file_iterator.first ();
            if (msg == null) return false;

            message_iterator = new MessageIterator (msg, search_info.search_text, filter_marks);
            MessageFragment mf = message_iterator.first ();
            if (mf == null) return next ();

            edit_panel.select (SelectLevel.STRING, mf);
            return true;
        }

        public override bool last ()
        {
            deselect ();

            Message msg = file_iterator.last ();
            if (msg == null) return false;

            message_iterator = new MessageIterator (msg, search_info.search_text, filter_marks);
            MessageFragment mf = message_iterator.last ();
            if (mf == null) return previous ();

            edit_panel.select (SelectLevel.STRING, mf);
            return true;
        }

        public void replace ()
        {
            MessageFragment? mf = message_iterator.current;

            if (mf == null || mf.is_original)
            return;

            string original_string = mf.message.get_translation (mf.plural_number);
            mf.message.set_translation (mf.plural_number,
                original_string.substring (0, mf.index) +
                search_info.replace_text +
                original_string.substring (mf.index + mf.length));
            next ();
        }

        public void select ()
        {
            MessageFragment mf = message_iterator.current;
            if (mf != null)
            edit_panel.select (SelectLevel.STRING, mf);
        }

        public void deselect ()
        {
            MessageFragment mf = message_iterator.current;
            if (mf != null)
            edit_panel.deselect (SelectLevel.STRING, mf);
        }
    }
}