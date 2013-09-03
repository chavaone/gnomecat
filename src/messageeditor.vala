/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of valacat
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
 *
 * valacat is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
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

using Gdl;
using Gtk;
using ValaCAT.FileProject;
using Gee;

namespace ValaCAT.UI
{

    /**
     * Editing pannel widget.
     */
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/messageeditor.ui")]
    public class MessageEditorWidget : DockItem, ChangedMessageSensible
    {
        [GtkChild]
        private Gtk.Notebook plurals_notebook;
        private Message message;

        public void set_message (Message m)
        {
            int i;
            this.clean_tabs ();
            string label = _("Singular (%s)").printf (m.get_language ().get_plural_form_tag (0));
            var auxtab = new MessageEditorTab (label, m, 0);
            foreach (MessageTip t in m.get_tips_plural_form (0))
                auxtab.add_tip (t);
            this.add_tab (auxtab);

            if (m.has_plural ())
            {
                int num_plurals = m.get_language ().get_number_of_plurals ();
                for (i = 1; i < num_plurals; i++)
                {
                    label = _("Plural %i (%s)").printf (i,m.get_language ().get_plural_form_tag (i));
                    auxtab = new MessageEditorTab (label, m, i);
                    foreach (MessageTip t in m.get_tips_plural_form (i))
                        auxtab.add_tip (t);
                    this.add_tab (auxtab);
                }
            }
            this.message = m;
        }

        public MessageEditorTab get_active_tab ()
        {
            int curr_page = this.plurals_notebook.get_current_page ();
            return this.plurals_notebook.get_nth_page (curr_page) as MessageEditorTab;
        }

        public MessageEditorTab? get_tab_by_plural_number (int plural_number)
        {
            if (plural_number > this.plurals_notebook.get_n_pages ())
                return null;

            return this.plurals_notebook.get_nth_page (plural_number) as MessageEditorTab;
        }

        public void select_tab_by_plural_number (int plural_number)
        {
            if (plural_number > this.plurals_notebook.get_n_pages ())
                return;
            this.plurals_notebook.set_current_page (plural_number);
        }

        private void add_tab (MessageEditorTab t)
        {
            this.plurals_notebook.append_page (t, t.label);
        }

        private void clean_tabs ()
        {
            int number_of_tabs = this.plurals_notebook.get_n_pages ();
            for (int i=0; i<number_of_tabs; i++)
            {
                this.plurals_notebook.remove_page (0);
            }
        }

    }

    /**
     * Editor pannel tabs.
     */
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/messageeditortab.ui")]
    public class MessageEditorTab : Box
    {

        /**
         * Label of this editor tab.
         */
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
        private string _tranlation_text;

        private string original_text
        {
            get {
                _original_text = this.plural_number == 0 ?
                this.message.get_original_singular () :
                this.message.get_original_plural ();
                return _original_text;
            }
        }

        private string? tranlation_text
        {
            get
            {
                _tranlation_text = this.message.get_translation (this.plural_number);
                return _tranlation_text;
            }
            set
            {
                this.message.set_translation (this.plural_number, value);
            }
        }

        public bool visible_whitespace {
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

        private ArrayList<ValaCAT.TextTag> original_text_tags;
        private ArrayList<ValaCAT.TextTag> translation_text_tags;
        private GLib.Settings settings;

        /**
         * Contructor for MessageEditorTabs. Initializes tab label
         *  and strings.
         */
        public MessageEditorTab (string label_text,
                                 Message message,
                                 int plural_number)
        {
            this.label = new Label (label_text);
            this.message = message;
            this.plural_number = plural_number;

            this.textview_original_text.buffer = new SourceBuffer (new TextTagTable ());
            this.textview_original_text.buffer.set_text (this.original_text);

            this.textview_translated_text.buffer = new SourceBuffer (new TextTagTable ());

            if (this.tranlation_text != null)
            {
                (this.textview_translated_text.buffer as SourceBuffer).begin_not_undoable_action ();
                this.textview_translated_text.buffer.set_text (this.tranlation_text);
                (this.textview_translated_text.buffer as SourceBuffer).end_not_undoable_action ();
            }

            this.original_text_tags = new ArrayList<ValaCAT.TextTag> ();
            this.translation_text_tags = new ArrayList<ValaCAT.TextTag> ();

            this.textview_translated_text.buffer.end_user_action.connect (update_translation);
        }

        construct
        {
            settings = new GLib.Settings ("info.aquelando.valacat");

            settings.bind ("highlight", this, "highlight_syntax", SettingsBindFlags.GET);
            settings.bind ("visible-whitespace", this, "visible_whitespace",SettingsBindFlags.GET);
            settings.bind ("font", this, "font", SettingsBindFlags.GET);
        }


        /**
         *
         */
        public void add_tip (MessageTip t)
        {
            this.tips_box.add (new MessageTipRow (t));
        }

        /**
         *
         */
        public void remove_tip (MessageTip t)
        {
            foreach (Widget w in this.tips_box.get_children ())
            {
                if ((w as MessageTipRow).tip == t)
                {
                    this.tips_box.remove (w);
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
                tt.add_to_buffer (this.textview_original_text.buffer, this.original_text.length);
                this.original_text_tags.add (tt);
            }
        }

        public void clean_tags_original_string ()
        {
            foreach (TextTag tt in this.original_text_tags)
                tt.remove_from_buffer (this.textview_original_text.buffer, this.original_text.length);
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
                tt.add_to_buffer (this.textview_translated_text.buffer, this.tranlation_text.length);
                this.translation_text_tags.add (tt);
            }
        }

        public void clean_tags_translation_string ()
        {
            foreach (TextTag tt in this.translation_text_tags)
                tt.remove_from_buffer (this.textview_translated_text.buffer, this.tranlation_text.length);
            this.translation_text_tags.clear ();
        }

        public void undo ()
        {
            SourceBuffer source_buffer = this.textview_translated_text.buffer as SourceBuffer;
            if (source_buffer.get_undo_manager (). can_undo ())
                source_buffer.get_undo_manager ().undo ();
        }

        public void redo ()
        {
            SourceBuffer source_buffer = this.textview_translated_text.buffer as SourceBuffer;
            if (source_buffer.get_undo_manager (). can_redo ())
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
            string? old_text = this.tranlation_text;
            string? new_text = buff.text;

            if (old_text == null && new_text != null)
            {
                this.message.state = settings.get_string ("message-changed-state") == "fuzzy" ?
                    MessageState.FUZZY :
                    MessageState.TRANSLATED;
            }

            if (old_text != null && new_text == "")
                this.message.state = MessageState.UNTRANSLATED;

            this.tranlation_text = new_text == "" ? null : new_text;
            this.message.message_changed ();
        }
    }

    /**
     * Rows of the tips displaying box.
     */
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/messageeditortabtiprow.ui")]
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
