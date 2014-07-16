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

namespace GNOMECAT.UI
{

    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/messageeditor.ui")]
    public class MessageEditor : Box
    {

        [GtkChild]
        Gtk.Notebook edit_notebook;

        [GtkChild]
        Gtk.ListBox tips;

        [GtkChild]
        Gtk.TextView context;

        [GtkChild]
        Gtk.Image img_btn_state;

        [GtkChild]
        Gtk.Button btn_state;


        private GLib.Settings settings;

        public string font
        {
            set
            {
                Pango.FontDescription font_desc = Pango.FontDescription.from_string (value);
                if (font_desc != null)
                {
                    context.override_font (font_desc);
                }

            }
        }

        private Message _message;
        public Message message
        {
            get
            {
                return _message;
            }
            set
            {
                _message = value;
                clean_tabs ();
                PluralForm enabled_plural_form = GNOMECAT.Application.get_default ().enabled_profile.plural_form;

                string label = _("Singular (%s)").printf (enabled_plural_form.plural_tags.get (0));
                add_tab (new MessageEditorTab (label, _message, 0));

                if (_message.has_plural () && enabled_plural_form != null)
                {
                    int num_plurals = enabled_plural_form.number_of_plurals;

                    for (int i = 1; i < num_plurals; i++)
                    {
                        label = _("Plural %i (%s)").printf (i, enabled_plural_form.plural_tags.get (i));
                        add_tab (new MessageEditorTab (label, _message, i));
                    }
                }

                context.buffer.text = value == null ? "" : value.get_context ();

                this.message.added_tip.connect (on_change_tips);
                this.message.removed_tip.connect (on_change_tips);
                this.message.notify["state"].connect (on_state_changed);
                this.message.message_changed.connect (on_message_changed);

                on_state_changed ();
                reload_tips ();
            }
        }

        construct
        {
            settings = new GLib.Settings ("org.gnome.gnomecat.Editor");

            settings.bind ("font", this, "font", SettingsBindFlags.GET);
        }

        private void clean_tabs ()
        {
            edit_notebook.foreach ( (w) => {edit_notebook.remove(w);});
        }

        private void add_tab (MessageEditorTab t)
        {
            edit_notebook.append_page (t, t.label);
        }

        public MessageEditorTab? get_active_tab ()
        {
            int curr_page = edit_notebook.get_current_page ();
            return edit_notebook.get_nth_page (curr_page) as MessageEditorTab;
        }

        public MessageEditorTab? get_tab_by_plural_number (int plural_number)
        {
            if (plural_number > edit_notebook.get_n_pages ())
                return null;

            return edit_notebook.get_nth_page (plural_number) as MessageEditorTab;
        }

        public void select_tab_by_plural_number (int plural_number)
        {
            if (plural_number > edit_notebook.get_n_pages ())
                return;
            edit_notebook.set_current_page (plural_number);
        }

        [GtkCallback]
        private void on_nth_pages_changed (Gtk.Widget pate, uint page_num)
        {
            edit_notebook.show_tabs = edit_notebook.get_n_pages () > 1;
        }

        private void on_change_tips (Message m, MessageTip t)
        {
            reload_tips ();
        }

        private void reload_tips ()
        {
            tips.foreach ((w) => {tips.remove(w);});
            foreach (MessageTip t in message.get_tips_plural_form (edit_notebook.page))
                tips.add (new MessageTipRow (t));
        }

        [GtkCallback]
        private void on_tip_enabled (ListBox source, ListBoxRow row)
        {
            get_active_tab ().replace_tags_original_string ((row as MessageTipRow).tip.tags_original);
            get_active_tab ().replace_tags_translation_string ((row as MessageTipRow).tip.tags_translation);
        }

        private void on_state_changed ()
        {
            switch (message.state)
            {
            case MessageState.TRANSLATED:
                btn_state.sensitive = true;
                img_btn_state.icon_name = "dialog-question-symbolic";
                break;
            case MessageState.FUZZY:
                btn_state.sensitive = true;
                img_btn_state.icon_name = "emblem-default-symbolic";
                break;
            case MessageState.UNTRANSLATED:
                btn_state.sensitive = false;
                break;
            }
        }

        private void on_message_changed ()
        {
            int length = message.tips.size;

            for (int i = 0; i < length; i++)
            {
                message.remove_tip (message.tips.get (0));
            }

            GNOMECAT.Application.get_default ().check_message (message);
        }

        public void select (GNOMECAT.SelectLevel level,
            GNOMECAT.MessageFragment? fragment)
        {
            assert (fragment != null);

            if (fragment.plural_number >= edit_notebook.get_n_pages ())
            {
                //TODO:include debug info!
                return;
            }

            edit_notebook.set_current_page (fragment.plural_number);
            if (level != SelectLevel.PLURAL)
            {
                (edit_notebook.get_nth_page (fragment.plural_number)
                    as MessageEditorTab).select (level, fragment);
            }
        }

        public void deselect (GNOMECAT.SelectLevel level,
            GNOMECAT.MessageFragment? fragment)
        {
            assert (fragment != null);

            if (fragment.plural_number < edit_notebook.get_n_pages () &&
                    level != SelectLevel.PLURAL)
            {
                (edit_notebook.get_nth_page (fragment.plural_number)
                    as MessageEditorTab).deselect (level, fragment);
            }
        }
    }


    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/messageeditortab.ui")]
    public class MessageEditorTab : Box
    {
        public Label label {get; private set;}
        public Message message {get; private set;}
        public int plural_number {get; private set;}

        [GtkChild]
        private SourceView textview_original_text;
        [GtkChild]
        private SourceView textview_translated_text;

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

        private string _translation_text;
        public string? translation_text
        {
            get
            {
                _translation_text = message.get_translation (this.plural_number);
                return _translation_text;
            }
            set
            {
                message.set_translation (plural_number, value);
                textview_translated_text.buffer.set_text (value == null ? "" : value);
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
        }

        construct
        {
            settings = new GLib.Settings ("org.gnome.gnomecat.Editor");

            settings.bind ("highlight", this, "highlight_syntax", SettingsBindFlags.GET);
            settings.bind ("visible-whitespace", this, "visible_whitespace",SettingsBindFlags.GET);
            settings.bind ("font", this, "font", SettingsBindFlags.GET);
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
            GNOMECAT.MessageFragment? fragment)
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
            GNOMECAT.MessageFragment? fragment)
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
    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/messagetiprow.ui")]
    public class MessageTipRow : ListBoxRow
    {

        public MessageTip tip {get; private set;}

        [GtkChild]
        private Image icon;
        [GtkChild]
        private Gtk.TextView tip_description;
        [GtkChild]
        private Gtk.Label tip_name;

        private GLib.Settings settings;

        public string font
        {
            set
            {
                Pango.FontDescription font_desc = Pango.FontDescription.from_string (value);
                if (font_desc != null)
                {
                    tip_description.override_font (font_desc);
                    if (tip_name.attributes == null)
                        tip_name.attributes = new Pango.AttrList ();
                    tip_name.attributes.change (new Pango.AttrFontDesc (font_desc));
                }

            }
        }

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
            tip_name.set_text (t.name);
            tip_description.buffer.text = t.description;
        }

        construct
        {
            settings = new GLib.Settings ("org.gnome.gnomecat.Editor");

            settings.bind ("font", this, "font", SettingsBindFlags.GET);
        }

        [GtkCallback]
        private bool on_selected (Gdk.EventButton e)
        {
            if (tip_description.visible)
            {
                tip_description.visible = false;
            }
            else
            {
                tip_description.visible = true;
                (this.get_parent() as ListBox).row_activated (this);
            }

            return false;
        }
    }
}