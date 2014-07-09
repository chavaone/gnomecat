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

namespace GNOMECAT
{
    public class Language : GLib.Object
    {
        public static Gee.HashMap<string,Language> languages {get; private set;}

        public string name {get; private set;}
        public string code {get; private set;}
        public GNOMECAT.PluralForm default_plural_form {get; set;}
        public string default_team_email {get; private set;}

        public int number_of_plurals
        {
            get
            {
                if (default_plural_form == null)
                    return 1;
                return default_plural_form.number_of_plurals;
            }
        }


        public static Language get_language_by_code (string code)
        {
            return languages.get (code);
        }

        public Language (string code, string name, string pluralform, string email)
        {
            this.name = name;
            this.code = code;
            this.default_plural_form = pluralform == "" ? null :
                GNOMECAT.PluralForm.get_plural_from_expression (pluralform);
            this.default_team_email = email;
        }


        public string? get_plural_form_tag (int plural)
        {
            if (default_plural_form == null)
                return null;
            return default_plural_form.get_plural_form_tag (plural);
        }

        static construct
        {
            languages = new Gee.HashMap<string, Language> ();

            try {
                var parser = new Json.Parser ();
                File file = File.new_for_uri ("resource:///org/gnome/gnomecat/languages.json");
                InputStream stream = file.read ();
                parser.load_from_stream (stream);

                var root_object = parser.get_root ().get_object ();

                foreach (var lang in root_object.get_array_member ("languages").get_elements ())
                {
                    var lang_object = lang.get_object ();

                    string name = lang_object.get_string_member ("name");
                    string code = lang_object.get_string_member ("code");
                    string plural_form_exp = lang_object.get_string_member ("pluralform");
                    string email = lang_object.get_string_member ("default-team-email");

                    languages.set (code, new Language (code, name, plural_form_exp, email));

                }
            } catch (Error e) {
                //TODO: print some error info.
                stderr.printf ("ERROR: %s\n",e.message);
            }
        }
    }
}