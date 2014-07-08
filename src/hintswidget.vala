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

using GNOMECAT.FileProject;

namespace GNOMECAT.UI
{

    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/hintpanelrow.ui")]
    public class HintPanelRow : Gtk.ListBoxRow
    {

        [GtkChild]
        private Gtk.TextView hint_text;
        [GtkChild]
        private Gtk.LevelBar accuracy;
        [GtkChild]
        private Gtk.Label origin;

        private GLib.Settings settings;

        public string font
        {
            set
            {
                Pango.FontDescription font_desc = Pango.FontDescription.from_string (value);
                if (font_desc != null)
                {
                    hint_text.override_font (font_desc);
                }

            }
        }


        private Hint _hint;
        public Hint hint
        {
            get
            {
                return _hint;
            }
            set
            {
                _hint = value;
                hint_text.buffer.text = value.translation_hint;
                origin.set_text (value.origin);
                accuracy.value = value.accuracy;
            }
        }

        public HintPanelRow (Hint h)
        {
            hint = h;
        }

        construct
        {
            settings = new GLib.Settings ("org.gnome.gnomecat.Editor");

            settings.bind ("font", this, "font", SettingsBindFlags.GET);
        }
    }

    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/hintpanelwidget.ui")]
    public class HintPanelWidget : Gtk.Box, ChangedMessageSensible
    {
        [GtkChild]
        private Gtk.ListBox hints_list;

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
                this.populate_list ();
            }
        }

        private void populate_list ()
        {
            hints_list.foreach ((w) => {
                hints_list.remove (w);
            });

            if (message == null)
                return;

            GNOMECAT.Application app = GNOMECAT.Application.get_default ();
            app.get_hints (this.message, this);
        }

        public void add_hint (Message m, Hint h)
        {
            if (m == this.message)
                hints_list.add (new HintPanelRow (h));
        }

        [GtkCallback]
        public void on_row_activated (Gtk.ListBoxRow r)
        {
            string text = (r as HintPanelRow).hint.translation_hint;
            GNOMECAT.UI.EditPanel w = parent.parent as GNOMECAT.UI.EditPanel;
            w.message_editor.get_active_tab ().translation_text = text;
            /*
            GNOMECAT.UI.MessageEditor w = (get_parent ().get_parent
                ().get_parent () as GNOMECAT.UI.EditPanel).message_list;
            w.get_active_editor_tab ().translation_text = text;
            */
        }
    }
}