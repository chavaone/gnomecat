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

 namespace GNOMECAT
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

    public class Search : GNOMECAT.Navigator
    {

        private string search_text;
        private string replace_text;
        private CheckMessageFunction msg_check_func;
        private CheckMessageFragmentFunction msg_frag_check_func;

        private GNOMECAT.UI.EditPanel edit_panel;

        private FileIterator file_iterator;
        private MessageIterator message_iterator;

        private GNOMECAT.File _file;
        public GNOMECAT.File file {
            get {
                return _file;
            }
            set {

                assert (value == edit_panel.file);

                _file = value;

                file_iterator = new FileIterator (value, msg_check_func);

                message_iterator = new MessageIterator (file_iterator.current,
                    search_text, msg_frag_check_func);
            }
        }

        public Search (GNOMECAT.UI.EditPanel edit_panel, SearchInfo search_info)
        {
            this.edit_panel = edit_panel;

            this.search_text = search_info.search_text;
            this.replace_text = search_info.replace_text;

            msg_check_func = (m) =>
                {
                    if (search_info.translated && m.state == MessageState.TRANSLATED)
                        return true;
                    if (search_info.untranslated && m.state == MessageState.UNTRANSLATED)
                        return true;
                    if (search_info.fuzzy && m.state == MessageState.FUZZY)
                        return true;
                    return false;
                };

            msg_frag_check_func = (mf) =>
                {
                    if (search_info.original  && mf.is_original)
                        return true;
                    if (search_info.translation && ! mf.is_original)
                        return true;
                    return false;
                };

            if (edit_panel.file != null)
            {
                this.file = edit_panel.file;
            }
        }

        public override bool next ()
        {
            deselect ();

            MessageFragment mf = message_iterator.next ();

            while (mf == null)
            {
                Message msg = file_iterator.next ();
                if (msg == null) return false;

                message_iterator = new MessageIterator (msg, search_text, msg_frag_check_func);
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

                message_iterator = new MessageIterator (msg, search_text, msg_frag_check_func);
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

            message_iterator = new MessageIterator (msg, search_text, msg_frag_check_func);
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

            message_iterator = new MessageIterator (msg, search_text, msg_frag_check_func);
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
                replace_text +
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