/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of GnomeCAT
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
 *
 * GnomeCAT is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * GnomeCAT is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with GnomeCAT. If not, see <http://www.gnu.org/licenses/>.
 */

using Gee;
using GnomeCAT.Languages;

namespace GnomeCAT.Profiles
{

    string string_random (int length = 8, string charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890")
    {
        string random = "";

        for (int i=0; i<length; i++)
        {
            int random_index = Random.int_range (0, charset.length);
            string ch = charset.get_char (charset.index_of_nth_char (random_index)).to_string ();
            random += ch;
        }

        return random;
    }


    public class Profile : Object
    {
        public string uuid {get; set;}
        public string name {get; set;}
        public string translator_name {get; set;}
        public string translator_email {get; set;}
        private Language _language;
        public Language language
        {
            get
            {
                _language = Language.get_language_by_code (this.language_code);
                return _language;
            }
            set
            {
                this.language_code = value.code;
            }
        }

        private PluralForm _plural_form;
        public PluralForm plural_form
        {
            get
            {
                _plural_form = PluralForm.get_plural_from_id (this.plural_form_id);
                return _plural_form;
            }
            set
            {
                this.plural_form_id = value.id;
            }
        }
        public bool enabled
        {
            get
            {
                GnomeCAT.Application app = GnomeCAT.Application.get_default();
                Profile? p = app.enabled_profile;
                return p != null && p.uuid == this.uuid;
            }
        }

        public string char_set {get; set;}
        public string encoding {get; set;}
        public string team_email {get; set;}

        private GLib.Settings set_prof;
        public string language_code {get; set;}
        public int plural_form_id {get; set;}


        public Profile (string name, string translator_name, string translator_email,
                        Language language, PluralForm plural_form, string char_set,
                        string encoding, string team_email)
        {
            string new_uuid = string_random (10); //FIXME: substitute by a call to uuid library.
            this.from_uuid (new_uuid);
            this.name = name;
            this.translator_name = translator_name;
            this.translator_email = translator_email;
            this.language = language;
            this.plural_form = plural_form;
            this.char_set = char_set;
            this.encoding = encoding;
            this.team_email = team_email;
        }

        public Profile.from_uuid (string uuid)
        {
            GLib.Settings set_prof = new GLib.Settings.with_path ("info.aquelando.GnomeCAT.Profile",
                "/info/aquelando/gnomecat/profiles:/" + uuid);

            this.uuid = uuid;
            set_prof.bind ("profile-name", this, "name",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("translator-name", this, "translator_name",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("translator-email", this, "translator_email",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("language", this, "language_code",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("plural-form", this, "plural_form_id",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("char-set", this, "char_set",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("encoding", this, "encoding",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("team-email", this, "team_email",  SettingsBindFlags.DEFAULT);

            string[] prof_arr = (new GLib.Settings ("info.aquelando.GnomeCAT.ProfilesList")).get_strv ("list");
            if (! (uuid in prof_arr))
                prof_arr += uuid;
            (new GLib.Settings ("info.aquelando.GnomeCAT.ProfilesList")).set_strv ("list", prof_arr);
        }

        construct
        {
            GnomeCAT.Application app = GnomeCAT.Application.get_default ();
            if (app.enabled_profile == null)
                app.enabled_profile = this;
        }

        public static ArrayList<Profile> get_profiles ()
        {
            string[] prof_arr = (new GLib.Settings ("info.aquelando.GnomeCAT.ProfilesList")).get_strv ("list");
            ArrayList<Profile> ret_arr = new ArrayList<Profile> ();

            foreach (string uuid in prof_arr)
                ret_arr.add (new Profile.from_uuid (uuid));
            return ret_arr;
        }

        public static void remove_profile (Profile p)
        {
            string[] prof_arr = (new GLib.Settings ("info.aquelando.GnomeCAT.ProfilesList")).get_strv ("list");
            string[] new_prof_arr = {};

            foreach (string prof in prof_arr)
                if (prof != p.uuid)
                    new_prof_arr += prof;
            (new GLib.Settings ("info.aquelando.GnomeCAT.ProfilesList")).set_strv ("list", new_prof_arr);
        }
    }
}

namespace GnomeCAT.UI
{
    [GtkTemplate (ui = "/info/aquelando/gnomecat/ui/profiledialog.ui")]
    public class ProfileDialog : Gtk.Dialog
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

        public ProfileDialog ()
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

        public ProfileDialog.from_profile (GnomeCAT.Profiles.Profile prof)
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