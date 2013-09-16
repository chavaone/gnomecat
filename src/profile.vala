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

using Gee;
using ValaCAT.Languages;

namespace ValaCAT.Profiles
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
            GLib.Settings set_prof = new GLib.Settings.with_path ("info.aquelando.valacat.Profile",
                "/info/aquelando/valacat/profiles:/" + uuid);

            this.uuid = uuid;
            set_prof.bind ("profile-name", this, "name",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("translator-name", this, "translator_name",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("translator-email", this, "translator_email",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("language", this, "language_code",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("plural-form", this, "plural_form_id",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("char-set", this, "char_set",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("encoding", this, "encoding",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("team-email", this, "team_email",  SettingsBindFlags.DEFAULT);

            string[] prof_arr = (new GLib.Settings ("info.aquelando.valacat.ProfilesList")).get_strv ("list");
            if (! (uuid in prof_arr))
                prof_arr += uuid;
            (new GLib.Settings ("info.aquelando.valacat.ProfilesList")).set_strv ("list", prof_arr);
        }

        public static ArrayList<Profile> get_profiles ()
        {
            string[] prof_arr = (new GLib.Settings ("info.aquelando.valacat.ProfilesList")).get_strv ("list");
            ArrayList<Profile> ret_arr = new ArrayList<Profile> ();

            foreach (string uuid in prof_arr)
                ret_arr.add (new Profile.from_uuid (uuid));
            return ret_arr;
        }

        public static void remove_profile (Profile p)
        {
            string[] prof_arr = (new GLib.Settings ("info.aquelando.valacat.ProfilesList")).get_strv ("list");
            string[] new_prof_arr = {};

            foreach (string prof in prof_arr)
                if (prof != p.uuid)
                    new_prof_arr += prof;
            (new GLib.Settings ("info.aquelando.valacat.ProfilesList")).set_strv ("list", new_prof_arr);
        }
    }
}

namespace ValaCAT.UI
{
    [GtkTemplate (ui = "/info/aquelando/valacat/ui/profiledialog.ui")]
    public class ProfileDialog : Gtk.Dialog
    {
        [GtkChild]
        private Gtk.Entry profile_name_entry;
        [GtkChild]
        private Gtk.Entry translator_name_entry;
        [GtkChild]
        private Gtk.Entry translator_email_entry;
        [GtkChild]
        private Gtk.ComboBox language_combobox;
        [GtkChild]
        private Gtk.ComboBox plural_form_combobox;
        [GtkChild]
        private Gtk.ComboBox encoding_combobox;
        [GtkChild]
        private Gtk.Entry team_email_entry;

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

        public string encoding
        {
            get
            {
                return "UTF-8";
            }
            set
            {
            }
        }

        private Language _language; //FIXME
        public Language language
        {
            get
            {
                _language = Language.get_language_by_code ("es"); //FIXME
                return _language;
            }
            set
            {
            }
        }

        public PluralForm plural_form
        {
            get
            {
                return Language.get_language_by_code ("es").plural_form; //FIXME
            }
            set
            {
            }
        }

        public ProfileDialog.from_profile (ValaCAT.Profiles.Profile prof)
        {
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