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

    [GtkTemplate (ui = "/info/aquelando/gnomecat/ui/hintpanelrow.ui")]
    public class HintPanelRow : Gtk.ListBoxRow
    {
        [GtkChild]
        private Gtk.Entry hint_entry;
        [GtkChild]
        private Gtk.Label origin;
        [GtkChild]
        private Gtk.Label accuracy_label;

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
                hint_entry.set_text (value.translation_hint);
                origin.set_text (value.origin);
                accuracy_label.set_text ((value.accuracy * 100).to_string () + "%");
            }
        }

        public HintPanelRow (Hint h)
        {
            hint = h;
        }
    }

    [GtkTemplate (ui = "/info/aquelando/gnomecat/ui/hintpanelwidget.ui")]
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
            GNOMECAT.UI.MessageListWidget w = (this.get_parent ().get_parent
                () as FileTab).message_list;
            w.get_active_editor_tab ().translation_text = text;
        }
    }
}

namespace GNOMECAT
{
    public class Hint : Object
    {
        public string translation_hint {get; private set;}
        public string origin {get; private set;}
        public double accuracy {get; private set;}

        public Hint (string translation_hint,
                    string origin,
                    double accuracy)
        {
            this.origin = origin;
            this.translation_hint = translation_hint;
            this.accuracy = accuracy;
        }
    }

    public abstract class HintProvider : Object
    {
        public abstract void get_hints (Message m, GNOMECAT.UI.HintPanelWidget hpw);
    }
}