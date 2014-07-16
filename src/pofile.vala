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

using GettextPo;


namespace GNOMECAT.PoFiles
{
    public class PoMessage : GNOMECAT.Message
    {
        protected unowned GettextPo.Message message;

        public Gee.ArrayList<GNOMECAT.MessageOrigin> _origins;
        public override Gee.ArrayList<GNOMECAT.MessageOrigin> origins
        {
            get
            {
                return _origins;
            }
        }

        private MessageState _state;
        public override MessageState state
        {
            get
            {
                return _state;
            }

            set
            {
                MessageState old_value = _state;

                bool untrans = false;

                int number_of_plurals = has_plural () ? GNOMECAT.Application.get_default ()
                    .enabled_profile.plural_form.number_of_plurals : 1;

                for (int i = 0; i < number_of_plurals && ! untrans; i++)
                {
                    untrans |= get_translation (i) == "";
                }

                _state = untrans ? MessageState.UNTRANSLATED :
                    value == MessageState.FUZZY ? MessageState.FUZZY :
                    MessageState.TRANSLATED;

                message.set_fuzzy (_state == MessageState.FUZZY);

                state_changed (old_value, _state);
                message_changed ();
            }
        }

        public PoMessage (PoFile owner_file, GettextPo.Message msg)
        {
            GettextPo.Filepos origin;

            base (owner_file);
            message = msg;

            state = msg.is_fuzzy () ? MessageState.FUZZY : MessageState.TRANSLATED;

            _origins = new Gee.ArrayList<GNOMECAT.MessageOrigin> ();

            for (int i = 0; (origin = message.filepos (i)) != null; i++)
            {
                _origins.add (new GNOMECAT.MessageOrigin (origin.file (), origin.start_line ()));
            }
        }


        /**
         * Method that indicates if this string has or has not
         *  a plural form.
         */
        public override bool has_plural ()
        {
            return this.message.msgid_plural () != null;
        }

        /**
         * Returns the originals singular text of this message.
         */
        public override string get_original_singular ()
        {
            return this.message.msgid ();
        }

        /**
         * Returns the original plural text of this message or
         *  \\null\\ if there is no plural.
         */
        public override string get_original_plural ()
        {
            return this.message.msgid_plural ();
        }

        /*
         * Gets the translated string that has the number
         *  provided by parameter.
         *
         * @param index Number of the requested translation.
         * @return The translated string.
         */
        public override string get_translation (int index)
        {
            return  index == 0 ?
                    this.message.msgstr () :
                    this.message.msgstr_plural (index - 1);
        }

        /*
         * Modifies the translated string that has the number
         *  provided by paramenter.
         *
         * @param index
         * @param translation
         * @return The previous string or \\null\\ if there
         *  isn't previous string
         */
        public override void set_translation_impl (int index,
                                            string? translation)
        {
            if (index == 0)
                this.message.set_msgstr (translation == null ? "" : translation);
            else
                this.message.set_msgstr_plural (index, translation == null ? "" : translation);
        }

        /**
         * Method that returns a string containing additional
         * information of this message such as context, translator
         * comments, etc.
         */
         public override string get_context ()
         {
            string ctx = "";
            string? format;
            if (this.message.comments () != "")
                ctx += "Coments:\n" + this.message.comments () + "\n";
            if (this.message.extracted_comments () != "")
                ctx += "Extracted Comments:\n" + this.message.extracted_comments () + "\n";
            if ((format = this.get_format ()) != null)
                ctx += "Format: " + GettextPo.format_pretty_name (format) + "\n";
            return ctx;

         }

         public string? get_format ()
         {
            foreach (string format in GettextPo.format_list ())
            {
                if (message.is_format (format))
                    return format;
            }

            return null;
         }
    }


    public class PoHeader : PoMessage
    {

        public PoHeader (PoFile owner_file, GettextPo.Message msg)
        {
            assert (msg.msgid () == "");
            base (owner_file, msg);
        }

        public string? get_info (string key)
        {
            return GettextPo.File.header_field (get_translation (0), key);
        }

        public void set_info (string key, string value)
        {
            string new_header = GettextPo.File.header_set_field (get_translation (0),
                                    key, value);
            set_translation_impl (0, new_header);
        }

        public void set_comment (string prof_name, string email, int curr_year)
        {
            string new_comment = "";
            string years_string = ", ";

            foreach (string line in message.comments ().split ("\n"))
            {
                if (! line.has_prefix (prof_name))
                {
                    if (line != "") new_comment += line + "\n";
                    continue;
                }

                years_string = ", ";

                foreach (string year in line.split (","))
                {
                    string year_parsed = year.has_suffix (".") ? year.substring (0, year.length - 1).strip () : year.strip ();
                    int64 year_int = 0;

                    if (year_parsed == "" || ! int64.try_parse (year_parsed, out year_int))
                        continue;

                    if (year_int != curr_year)
                        years_string += "%s, ".printf (year_parsed);
                }
            }

            new_comment += "%s <%s>%s%i.\n\n\n".printf (prof_name, email, years_string, curr_year);
            message.set_comments (new_comment);
        }

    }


    public class PoFile : GNOMECAT.File
    {
        private GettextPo.File file;
        private PoHeader header;

        public PoFile.full (string path, Project? p)
        {
            base.full (path, p);
        }

        /**
         * Method that saves the instance of this File into
         *  a file indicated as parameter.
         */
        protected override void save_file (string file_path)
        {
            XErrorHandler err_hand = XErrorHandler ();
            update_header_info ();
            GettextPo.File.file_write (file, file_path, err_hand);
        }

        /**
         * Method that parses a file in order to populate
         *  this instance of File.
         */
        public override void parse (string path)
        {
            XErrorHandler err_hand = XErrorHandler ();
            this.file = GettextPo.File.file_read (path, err_hand);
            foreach (string d in this.file.domains ())
            {
                MessageIterator mi = this.file.message_iterator (d);
                unowned GettextPo.Message m;
                while ((m = mi.next_message ()) != null)
                {
                    if (m.msgid () == "")
                        this.header = new PoHeader (this, m);
                    else if (! m.is_obsolete ())
                        this.add_message (new PoMessage (this, m));
                }
            }
        }

        public override string? get_info (string key)
        {
            if (header == null)
                return null;

            return header.get_info (key);
        }

        public override void set_info (string key, string value)
        {
            if (header == null)
                return;

            header.set_info (key, value);
        }

        private void update_header_info ()
        {
            GNOMECAT.Profiles.Profile profile = GNOMECAT.Application.get_default ().enabled_profile;
            string last_translator = "%s <%s>".printf (profile.translator_name, profile.translator_email);
            set_info ("Last-Translator", last_translator);

            set_info ("X-Generator", "GNOMECAT " + Config.VERSION);

            DateTime now = new DateTime.now_local ();
            header.set_comment (profile.translator_name, profile.translator_email, now.get_year ());
        }
    }


    public class PoFileOpener : FileOpener
    {
        private static string[] ext = {"po"};

        public override string[] extensions
        {
            get
            {
                return ext;
            }
        }


        public override GNOMECAT.File? open_file (string path, Project? p)
        {
            return new PoFile.full (path, p);
        }
    }
}