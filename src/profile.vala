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

namespace GNOMECAT
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
                _plural_form = PluralForm.get_plural_from_expression (plural_form_exp);
                return _plural_form;
            }
            set
            {
                plural_form_exp = value.expression;
            }
        }
        public bool enabled
        {
            get
            {
                GNOMECAT.Application app = GNOMECAT.Application.get_default ();
                Profile? p = app.enabled_profile;
                return p != null && p.uuid == this.uuid;
            }
            set
            {
                GNOMECAT.Application app = GNOMECAT.Application.get_default ();

                if (value)
                {
                    app.enabled_profile = this;
                }
                else if (app.enabled_profile == this)
                {
                    if (get_profiles ().size == 1)
                    {
                        app.enabled_profile = null;
                    }
                    else
                    {
                        app.enabled_profile = get_profiles ().get (0);
                    }
                }
            }
        }

        public string char_set {get; set;}
        public string encoding {get; set;}
        public string team_email {get; set;}

        public string language_code {get; set;}
        public string plural_form_exp {get; set;}


        public Profile (string name, string translator_name, string translator_email,
                        GNOMECAT.Language language, GNOMECAT.PluralForm plural_form, string char_set,
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
            string new_path = "/org/gnome/gnomecat/profiles:/:%s/".printf (uuid);
            GLib.Settings set_prof = new GLib.Settings.with_path ("org.gnome.gnomecat.Profile",
                new_path);

            this.uuid = uuid;
            set_prof.bind ("profile-name", this, "name",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("translator-name", this, "translator_name",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("translator-email", this, "translator_email",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("language", this, "language_code",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("plural-form", this, "plural_form_exp",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("char-set", this, "char_set",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("encoding", this, "encoding",  SettingsBindFlags.DEFAULT);
            set_prof.bind ("team-email", this, "team_email",  SettingsBindFlags.DEFAULT);
        }

        public void save ()
        {
            GLib.Settings set_prof_list = new GLib.Settings ("org.gnome.gnomecat.ProfilesList");
            string[] prof_arr = set_prof_list.get_strv ("list");
            if (! (uuid in prof_arr))
                prof_arr += uuid;
            set_prof_list.set_strv ("list", prof_arr);
        }

        public void remove ()
        {
            GLib.Settings set_prof_list = new GLib.Settings ("org.gnome.gnomecat.ProfilesList");
            string[] prof_arr = set_prof_list.get_strv ("list");
            string[] new_prof_arr = {};

            foreach (string prof in prof_arr)
                if (prof != this.uuid)
                    new_prof_arr += prof;
            set_prof_list.set_strv ("list", new_prof_arr);

            this.enabled == false;
        }

        public static ArrayList<Profile> get_profiles ()
        {
            GLib.Settings set_prof_list = new GLib.Settings ("org.gnome.gnomecat.ProfilesList");
            string[] prof_arr = set_prof_list.get_strv ("list");
            ArrayList<Profile> ret_arr = new ArrayList<Profile> ();

            foreach (string uuid in prof_arr)
                ret_arr.add (new Profile.from_uuid (uuid));
            return ret_arr;
        }
    }
}