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

using Gtk;
using Gee;
using ValaCAT.FileProject;
using ValaCAT.Iterators;
using ValaCAT.Search;
using ValaCAT.UI;

namespace ValaCAT.UI
{
    public enum SearchDialogResponses
    {
        CANCEL  = 0,
        SEARCH = 1,
        REPLACE = 2,
        REPLACEALL = 3;
    }


    /**
     *
     */
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/searchdialog.ui")]
    public class SearchDialog : Gtk.Dialog
    {
        [GtkChild]
        private Gtk.Entry entry_search;
        [GtkChild]
        private Gtk.Entry entry_replace;
        [GtkChild]
        private Gtk.CheckButton checkbutton_translated_messages;
        [GtkChild]
        private Gtk.CheckButton checkbutton_fuzzy_messages;
        [GtkChild]
        private Gtk.CheckButton checkbutton_untranslated_messages;
        [GtkChild]
        private Gtk.CheckButton checkbutton_translated;
        [GtkChild]
        private Gtk.CheckButton checkbutton_original;
        [GtkChild]
        private Gtk.CheckButton checkbutton_search_project;
        [GtkChild]
        private Gtk.CheckButton checkbutton_wrap_around;

        public string search_text {get { return entry_search.get_text ();}}
        public string replace_text {get {return entry_replace.get_text ();}}
        public bool translated_messages {get {return checkbutton_translated_messages.active;}}
        public bool fuzzy_messages {get {return checkbutton_fuzzy_messages.active;}}
        public bool untranslated_messages {get {return checkbutton_untranslated_messages.active;}}
        public bool translation_text {get {return checkbutton_translated.active;}}
        public bool original_text {get {return checkbutton_original.active;}}
        public bool search_project {get {return checkbutton_search_project.active;}}
        public bool wrap_around {get {return checkbutton_wrap_around.active;}}

        [GtkCallback]
        private void on_close ()
        {
            this.response (ValaCAT.UI.SearchDialogResponses.CANCEL);
        }
    }
}


namespace ValaCAT.Search
{
    public abstract class Search : Object
    {
        public abstract string search_text {get; set;}

        public abstract string replace_text {get; set;}

        public abstract void next_item ();

        public abstract void previous_item ();

        public abstract void replace ();

        public abstract void disable ();
    }


    /*
    public class ProjectSearch : Search
    {
    }
    */

    public class FileSearch : Search
    {

        private ValaCAT.UI.FileTab filetab;
        private FileIterator file_iterator;
        private MessageIterator message_iterator;
        public override string replace_text {get; private set;}
        public override string search_text {get; private set;}


        public FileSearch (ValaCAT.UI.FileTab tab,
                         bool translated,
                         bool untranslated,
                         bool fuzzy,
                         bool original,
                         bool translation,
                         string search_text,
                         string replace_text)
        {

            //FILTERS MESSAGES
            ArrayList<IteratorFilter<Message>> filters_file = new ArrayList<IteratorFilter<Message>> ();
            if (translated)
                filters_file.add (new TranslatedFilter ());

            if (untranslated)
                filters_file.add (new UntranslatedFilter ());

            if (fuzzy)
                filters_file.add (new FuzzyFilter ());


            IteratorFilter<Message> filter_messages;

            if (filters_file.size == 0)
                filter_messages = null;
            else if (filters_file.size == 1)
                filter_messages = filters_file.get (0);
            else
                filter_messages = new ORFilter<Message> (filters_file);


            //FILTERS MESSAGE MARKS
            ArrayList<IteratorFilter<MessageFragment>> filters_mark_array = new ArrayList<IteratorFilter<MessageFragment>> ();
            if (original)
                filters_mark_array.add (new OriginalFilter ());

            if (translation)
                filters_mark_array.add (new TranslationFilter ());


            IteratorFilter<MessageFragment> filter_marks;
            if (filters_mark_array.size == 0)
                filter_marks = null;
            else if (filters_mark_array.size == 1)
                filter_marks = filters_mark_array.get (0);
            else
                filter_marks = new ORFilter<MessageFragment> (filters_mark_array);


            this.filetab = tab;
            this.file_iterator = new FileIterator (tab.file,filter_messages);
            this.file_iterator.first ();
            this.message_iterator = new MessageIterator (null, search_text, filter_marks);
            this.replace_text = replace_text;
            this.search_text = search_text;
        }

        public override void next_item ()
        {
            MessageFragment mf = null;

            while (mf == null)
            {
                if (this.message_iterator.message == null || (mf = this.message_iterator.next ()) == null)
                {
                    Message message;;
                    if ((message = this.file_iterator.next ()) == null)
                        return;
                    this.message_iterator.set_element (message);
                    this.message_iterator.first ();
                }
            }

            ValaCAT.Application.get_default ().select (SelectLevel.STRING, mf);
        }

        public override void previous_item ()
        {
            MessageFragment mf = null;

            while (mf == null)
            {
                if (this.message_iterator.message == null || (mf = this.message_iterator.previous ()) == null)
                {
                    Message message;;
                    if ((message = this.file_iterator.previous ()) == null)
                        return;
                    this.message_iterator.set_element (message);
                    this.message_iterator.last ();
                }
            }

            ValaCAT.Application.get_default ().select (SelectLevel.STRING, mf);
        }

        public override void replace ()
        {
            MessageFragment mf = this.message_iterator.get_current_element ();
            replace_intern (mf);
        }

        public override void disable ()
        {
            MessageFragment mf = this.message_iterator.get_current_element ();
            if (mf != null)
                un_highligt_search (mf);
        }

        private void un_highligt_search (MessageFragment mf)
        {
            ValaCAT.UI.MessageListRow? row = filetab.message_list.get_row_by_message (mf.message);

            if (row == null) return;

            filetab.message_list.select_row (row);
            filetab.message_list.select_editor_tab (mf.plural_number);

            MessageEditorTab editor_tab = filetab.message_list.get_tab_by_plural_number (mf.plural_number);
            editor_tab.clean_tags_translation_string ();
            editor_tab.clean_tags_original_string ();
        }

        private void replace_intern (MessageFragment mf)
        {
            if (mf.is_original)
            {
                return;
            }
            else
            {
                string original_string = mf.message.get_translation (mf.plural_number);
                mf.message.set_translation (mf.plural_number,
                    original_string.substring (0,mf.index) + this.replace_text +
                    original_string.substring (mf.index + mf.length));
            }
        }
    }
}