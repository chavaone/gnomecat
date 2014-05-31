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

using Gee;
using GNOMECAT.Languages;

namespace GNOMECAT.UI
{
    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/simpleprofilepanel.ui")]
    public class SimpleProfilePanel : Gtk.Grid
    {

        [GtkChild]
        private Gtk.Entry profile_name_entry;
        public string profile_name
        {
            get
            {
                return profile_name_entry.text;
            }
            set
            {
                profile_name_entry.text = value;
            }
        }

        [GtkChild]
        private Gtk.Entry translator_name_entry;
        public string translator_name
        {
            get
            {
                return translator_name_entry.text;
            }
            set
            {
                translator_name_entry.text = value;
            }
        }

        [GtkChild]
        private Gtk.Entry translator_email_entry;
        public string translator_email
        {
            get
            {
                return translator_email_entry.text;
            }
            set
            {
                translator_email_entry.text = value;
            }
        }

        [GtkChild]
        private Gtk.Entry team_email_entry;
        public string team_email
        {
            get
            {
                return team_email_entry.text;
            }
            set
            {
                team_email_entry.text = value;
            }
        }

        [GtkChild]
        private Gtk.ComboBoxText encoding_combobox;
        public string encoding
        {
            get
            {
                return "UTF-8"; //FIXME
            }
            set
            {
            }
        }

        [GtkChild]
        private Gtk.ComboBoxText language_combobox;
        public Language? language
        {
            get
            {
                int active_item = language_combobox.get_active ();
                if (active_item == -1)
                    return null;

                foreach (var entry in Language.languages.entries)
                    if (active_item-- == 0)
                        return entry.value;
                return null;
            }
            set
            {
                int index = 0;
                foreach (var entry in Language.languages.entries)
                {
                    if (entry.value == value)
                        plural_form_combobox.active = index;
                    index++;
                }
            }
        }

        [GtkChild]
        private Gtk.ComboBoxText plural_form_combobox;
        public PluralForm? plural_form
        {
            get
            {
                int active_item = plural_form_combobox.get_active ();
                if (active_item == -1)
                    return null;

                foreach (var entry in PluralForm.plural_forms.entries)
                    if (active_item-- == 0)
                        return entry.value;
                return null;
            }
            set
            {
                int index = 0;
                foreach (var entry in PluralForm.plural_forms.entries)
                {
                    if (entry.value == value)
                        plural_form_combobox.active = index;
                    index++;
                }
            }
        }

        public SimpleProfilePanel ()
        {
            foreach (var entry in Language.languages.entries)
            {
                language_combobox.append_text (entry.value.name + " (" + entry.key + ")");
            }

            foreach (PluralForm pf in PluralForm.plural_forms)
            {
                plural_form_combobox.append_text (pf.expression);
            }
        }

        public SimpleProfilePanel.from_profile (GNOMECAT.Profiles.Profile prof)
        {
            this ();
            this.profile_name = prof.name;
            this.translator_name = prof.translator_name;
            this.translator_email = prof.translator_email;
            this.team_email = prof.team_email;
            this.encoding = prof.encoding;
            this.language = prof.language;
            this.plural_form = prof.plural_form;
        }
    }
}