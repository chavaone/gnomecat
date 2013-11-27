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
using GNOMECAT.FileProject;
using GNOMECAT.Languages;
using Gee;

namespace GNOMECAT.UI
{

    int string_lines (string s)
    {
        int index, ret;
        for (ret = 1, index = -1; (index = s.index_of_char ('\n', index+1)) != -1; ret++);
        return ret;
    }

    /**
     * Editor pannel tabs.
     */
    [GtkTemplate (ui = "/info/aquelando/gnomecat/ui/messageeditortab.ui")]
    public class MessageEditorTab : Box
    {
        public Label label {get; private set;}
        public Message message {get; private set;}
        public int plural_number {get; private set;}

        [GtkChild]
        private SourceView textview_original_text;
        [GtkChild]
        private SourceView textview_translated_text;
        [GtkChild]
        private ListBox tips_box;

        private string _original_text;
        public string original_text
        {
            get
            {
                _original_text = this.plural_number == 0 ?
                this.message.get_original_singular () :
                this.message.get_original_plural ();
                return _original_text;
            }
        }

        private string _tranlation_text;
        public string? translation_text
        {
            get
            {
                _tranlation_text = this.message.get_translation (this.plural_number);
                return _tranlation_text;
            }
            set
            {
                string old_text = translation_text;
                string new_text = value;

                message.set_translation (this.plural_number, new_text);
                if (old_text != null && new_text == "")
                this.message.state = MessageState.UNTRANSLATED;

                if (old_text == null && new_text != null)
                {
                    bool untrans_msg = false;
                    PluralForm enabled_plural_form = GNOMECAT.Application.get_default ().enabled_profile.plural_form;
                    int num_plurals = message.has_plural () ?
                        enabled_plural_form.number_of_plurals : 1;
                    for (int i = 0; i < num_plurals; i++)
                        untrans_msg |= message.get_translation (i) == null;

                    if (! untrans_msg)
                        this.message.state = settings.get_string ("message-changed-state") == "fuzzy" ?
                            MessageState.FUZZY :
                            MessageState.TRANSLATED;
                }
                textview_translated_text.buffer.set_text (new_text);
                message.message_changed ();
            }
        }

        public bool visible_whitespace
        {
            get
            {
                assert (textview_translated_text.draw_spaces == textview_original_text.draw_spaces);
                return textview_translated_text.draw_spaces == SourceDrawSpacesFlags.ALL;
            }
            set
            {
                if (value)
                {
                    textview_translated_text.draw_spaces = SourceDrawSpacesFlags.ALL;
                    textview_original_text.draw_spaces = SourceDrawSpacesFlags.ALL;
                }
                else
                {
                    textview_translated_text.draw_spaces = SourceDrawSpacesFlags.LEADING;
                    textview_original_text.draw_spaces = SourceDrawSpacesFlags.LEADING;
                }
            }
        }

        public bool highlight_syntax
        {
            get
            {
                assert ((textview_translated_text.buffer as SourceBuffer).highlight_syntax ==
                    (textview_original_text.buffer as SourceBuffer).highlight_syntax);
                return (textview_translated_text.buffer as SourceBuffer).highlight_syntax;
            }
            construct set
            {
                (textview_translated_text.buffer as SourceBuffer).highlight_syntax = value;
                (textview_original_text.buffer as SourceBuffer).highlight_syntax = value;
            }
        }

        public string font
        {
            set
            {
                Pango.FontDescription font_desc = Pango.FontDescription.from_string (value);
                if (font_desc != null)
                {
                    textview_translated_text.override_font (font_desc);
                    textview_original_text.override_font (font_desc);
                }

            }
        }

        private ArrayList<GNOMECAT.TextTag> original_text_tags;
        private ArrayList<GNOMECAT.TextTag> translation_text_tags;
        private GLib.Settings settings;

        /**
         * Contructor for MessageEditorTabs. Initializes tab label
         *  and strings.
         */
        public MessageEditorTab (string label_text,
                                 Message message,
                                 int plural_number)
        {
            label = new Label (label_text);
            this.message = message;
            this.plural_number = plural_number;

            SourceLanguageManager lang_manager = new SourceLanguageManager ();
            weak string[] old_path = lang_manager.get_search_path ();

            string[] new_path = {};
            foreach (string s in old_path)
                new_path += s;
            new_path += Config.DATADIR;

            lang_manager.set_search_path (new_path);

            SourceLanguage lang = lang_manager.get_language ("gtranslator");

            textview_original_text.buffer = new SourceBuffer.with_language (lang);
            textview_original_text.buffer.set_text (original_text);

            textview_translated_text.buffer = new SourceBuffer.with_language (lang);

            if (translation_text != null)
            {
                (textview_translated_text.buffer as SourceBuffer).begin_not_undoable_action ();
                textview_translated_text.buffer.set_text (this.translation_text);
                (textview_translated_text.buffer as SourceBuffer).end_not_undoable_action ();
            }

            original_text_tags = new ArrayList<GNOMECAT.TextTag> ();
            translation_text_tags = new ArrayList<GNOMECAT.TextTag> ();

            textview_translated_text.buffer.end_user_action.connect (update_translation);

            foreach (MessageTip t in message.get_tips_plural_form (plural_number))
                add_tip (t);

            int height_orig = string_lines (original_text) * 25;
            int height_tran = string_lines (translation_text) * 25;
            int height = height_orig > height_tran ? height_orig : height_tran;
            height = height > 225 ? 225 : height;
            textview_original_text.height_request = height;
            textview_translated_text.height_request = height;
            this.height_request = height * 2 + 60;

            this.message.added_tip.connect (on_added_tip);
            this.message.removed_tip.connect (on_removed_tip);
        }

        construct
        {
            settings = new GLib.Settings ("info.aquelando.gnomecat.Editor");

            settings.bind ("highlight", this, "highlight_syntax", SettingsBindFlags.GET);
            settings.bind ("visible-whitespace", this, "visible_whitespace",SettingsBindFlags.GET);
            settings.bind ("font", this, "font", SettingsBindFlags.GET);
        }

        private void on_added_tip (Message m, MessageTip t)
        {
            add_tip (t);
        }

        private void on_removed_tip (Message m, MessageTip t)
        {
            remove_tip (t);
        }

        public void add_tip (MessageTip t)
        {
            tips_box.add (new MessageTipRow (t));
        }

        public void remove_tip (MessageTip t)
        {
            foreach (Widget w in tips_box.get_children ())
            {
                if ((w as MessageTipRow).tip == t)
                {
                    tips_box.remove (w);
                    return;
                }
            }
        }

        public void replace_tags_original_string (ArrayList<TextTag> tags)
        {
            this.clean_tags_original_string ();
            this.add_tags_original_string (tags);
        }

        public void add_tags_original_string (ArrayList<TextTag> tags)
        {
            foreach (TextTag tt in tags)
            {
                add_tag_to_buffer (tt, this.textview_original_text.buffer, this.original_text.length);
                this.original_text_tags.add (tt);
            }
        }

        public void clean_tags_original_string ()
        {
            foreach (TextTag tt in this.original_text_tags)
                remove_tag_from_buffer (tt, this.textview_original_text.buffer, this.original_text.length);
            this.original_text_tags.clear ();
        }

        public void replace_tags_translation_string (ArrayList<TextTag> tags)
        {
            this.clean_tags_translation_string ();
            this.add_tags_translation_string (tags);
        }

        public void add_tags_translation_string (ArrayList<TextTag> tags)
        {
            foreach (TextTag tt in tags)
            {
                add_tag_to_buffer (tt, this.textview_translated_text.buffer, this.translation_text.length);
                this.translation_text_tags.add (tt);
            }
        }

        public void clean_tags_translation_string ()
        {
            foreach (TextTag tt in this.translation_text_tags)
                remove_tag_from_buffer (tt, this.textview_translated_text.buffer, this.translation_text.length);
            this.translation_text_tags.clear ();
        }

        public void undo ()
        {
            SourceBuffer source_buffer = this.textview_translated_text.buffer as SourceBuffer;
            if (source_buffer.get_undo_manager ().can_undo ())
                source_buffer.get_undo_manager ().undo ();
        }

        public void redo ()
        {
            SourceBuffer source_buffer = this.textview_translated_text.buffer as SourceBuffer;
            if (source_buffer.get_undo_manager ().can_redo ())
                source_buffer.get_undo_manager ().redo ();
        }

        [GtkCallback]
        private void tip_enabled (ListBox source, ListBoxRow row)
        {
            this.replace_tags_original_string ((row as MessageTipRow).tip.tags_original);
            this.replace_tags_translation_string ((row as MessageTipRow).tip.tags_translation);
        }

        private void update_translation (TextBuffer buff)
        {
            string? new_text = buff.text;
            translation_text = new_text == "" ? null : new_text;
        }

        private void add_tag_to_buffer (GNOMECAT.TextTag tag, TextBuffer buffer, int text_size)
        {
            TextIter ini_iter = TextIter ();
            if (tag.ini_offset == -1)
                buffer.get_iter_at_offset (out ini_iter, 0);
            else
                buffer.get_iter_at_offset (out ini_iter, tag.ini_offset);

            TextIter end_iter = TextIter ();
            if (tag.end_offset == -1)
                buffer.get_iter_at_offset (out end_iter, text_size - 1);
            else
                buffer.get_iter_at_offset (out end_iter, tag.end_offset);

            buffer.tag_table.add (tag.tag);
            buffer.apply_tag_by_name (tag.tag.name, ini_iter, end_iter);
        }


        public void remove_tag_from_buffer (GNOMECAT.TextTag tag, TextBuffer buffer, int text_size)
        {
            TextIter ini_iter = TextIter ();
            if (tag.ini_offset == -1)
                buffer.get_iter_at_offset (out ini_iter, 0);
            else
                buffer.get_iter_at_offset (out ini_iter, tag.ini_offset);

            TextIter end_iter = TextIter ();
            if (tag.end_offset == -1)
                buffer.get_iter_at_offset (out end_iter, text_size - 1);
            else
                buffer.get_iter_at_offset (out end_iter, tag.end_offset);

            buffer.remove_tag_by_name (tag.tag.name, ini_iter, end_iter);
            buffer.tag_table.remove (tag.tag);
        }

        public void select (GNOMECAT.SelectLevel level,
            GNOMECAT.FileProject.MessageFragment? fragment)
        {
            assert (level == SelectLevel.STRING);
            assert (fragment != null);

            ArrayList<GNOMECAT.TextTag> arr = new ArrayList<GNOMECAT.TextTag> ();
            arr.add (new GNOMECAT.TextTag.from_message_fragment (fragment, "search_tag"));

            if (fragment.is_original)
            {
                replace_tags_original_string (arr);
            }
            else
            {
                replace_tags_translation_string (arr);
            }
        }

        public void deselect (GNOMECAT.SelectLevel level,
            GNOMECAT.FileProject.MessageFragment? fragment)
        {
            assert (level == SelectLevel.STRING);
            assert (fragment != null);

            if (fragment.is_original)
            {
                clean_tags_original_string ();
            }
            else
            {
                clean_tags_translation_string ();
            }
        }
    }


    /**
     * Rows of the tips displaying box.
     */
    [GtkTemplate (ui = "/info/aquelando/gnomecat/ui/messageeditortabtiprow.ui")]
    public class MessageTipRow : ListBoxRow
    {

        /**
         *
         */
        public MessageTip tip {get; private set;}

        [GtkChild]
        private Image icon;

        /**
         *
         */
        public MessageTipRow (MessageTip t)
        {
            this.tip = t;

            switch (t.level)
            {
            case TipLevel.ERROR:
                icon.icon_name = "dialog-error-symbolic";
                break;
            case TipLevel.WARNING:
                icon.icon_name = "dialog-warning-symbolic";
                break;
            case TipLevel.INFO:
                icon.icon_name = "dialog-information-symbolic";
                break;
            }
            icon.tooltip_text = t.name + ": " + t.description;
        }
    }
}