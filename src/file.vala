/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of Gnomecat
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
 *
 * Gnomecat is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Gnomecat is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Gnomecat. If not, see <http://www.gnu.org/licenses/>.
 */

using Gee;

namespace GNOMECAT
{
    /**
     * Class that encapsulates a method to open files of
     *  certain types.
     */
    public abstract class FileOpener
    {
        public abstract string[] extensions {get;}
        public abstract File? open_file (string path, Project? p);
    }


    /**
     * Enum for the levels of Message Tips.
     */
    public enum TipLevel
    {
        INFO,
        WARNING,
        ERROR
    }


    /**
     * This class represents information that can be added to Messages in order
     *  to indicate that they have some failure or something that can be
     *  improved.
     */
    public class MessageTip : Object
    {

        /**
         * Name of the MessageTip.
         */
        public string name {get; private set;}

        /*
         * Description of the MessageTip.
         */
        public string description {get; private set;}

        /*
         * Description of the MessageTip. It can be **INFO**, **WARNING** or **ERROR**.
         */
        public TipLevel level {get; private set;}

        /**
         * Tags that can be added to the original string.
         */
        public ArrayList<GNOMECAT.TextTag> tags_original {get; private set;}

        /**
         * Tags that can be added to the translated string.
         */
        public ArrayList<GNOMECAT.TextTag> tags_translation {get; private set;}

        /**
         * Plural form this tip references.
         */
        public int plural_number {get; private set;}


        /**
         * Contructor.
         *
         * @param name
         * @param description
         * @param level
         * @param tags_original
         * @param tags_translation
         */
        public MessageTip (string name,
                string? description,
                TipLevel level,
                ArrayList<GNOMECAT.TextTag>? tags_original=null,
                ArrayList<GNOMECAT.TextTag>? tags_translation=null)
        {
            this.name = name;
            this.description = description;
            this.level = level;
            this.tags_original = tags_original != null ? tags_original : new ArrayList<GNOMECAT.TextTag> ();
            this.tags_translation = tags_translation != null ? tags_translation : new ArrayList<GNOMECAT.TextTag> ();
        }
    }

    /**
     * Object that represents certain portion of a message.
     */
    public class MessageFragment : Object
    {

        public Message message {get; private set;}
        public int plural_number {get; private set;}
        public bool is_original {get; private set;}
        public int index {get; private set;}
        public int length {get; private set;}
        public File file
        {
            get
            {
                return this.message.file;
            }
        }
        public Project? project
        {
            get
            {
                if (this.message.file != null)
                {
                    return this.message.file.project;
                }
                return null;
            }
        }

        public MessageFragment (Message m, int plural_number, bool is_original, int index, int length)
        {
            this.message = m;
            this.plural_number = plural_number;
            this.is_original = is_original;
            this.index = index;
            this.length = length;
        }
    }


    /**
     * State of a message.
     */
    public enum MessageState
    {
        TRANSLATED,
        UNTRANSLATED,
        FUZZY,
        OBSOLETE
    }

    public class MessageOrigin : Object
    {
        public string file {get; set construct;}
        public size_t line {get; set construct;}

        public MessageOrigin (string file, size_t line)
        {
            Object(file:file, line:line);
        }
    }


    /**
     * Represents a instace of each message to be translated.
     */
    public abstract class Message : Object
    {

        /**
         * File which is the owner of this message.
         */
        public File file {get; private set; default = null;}

        /**
         * State of the message.
         */
        public abstract MessageState state
        {
            get;
            set;
        }

        public abstract ArrayList<GNOMECAT.MessageOrigin> origins
        {
            get;
        }

        /*
         * List of tips that this message has.
         */
        public ArrayList<MessageTip> tips {get; private set; default = null;}


        /*
         * Contructor for Message objects.
         *
         * @param owner_file
         */
        public Message (File owner_file)
        {
            this.file = owner_file;
            this.tips = new ArrayList<MessageTip> ();
        }

        /**
         * Signal emited when a new tip is added to this message.
         *
         * @param tip Added tip.
         */
        public signal void added_tip (MessageTip tip);

        /**
         * Signal emited when a new tip is deleted from this message.
         *
         * @param tip Deleted tip.
         */
        public signal void removed_tip (MessageTip tip);

        /**
         * Signal emited when the message changed.
         */
        public signal void message_changed ();

        /**
         * Signal emited when the message changed.
         */
        public signal void state_changed (MessageState old_state, MessageState new_state);

        /**
         * Method that indicates if this string has or has not
         *  a plural form.
         */
        public abstract bool has_plural ();

        /**
         * Returns the originals singular text of this message.
         */
        public abstract string get_original_singular ();

        /**
         * Returns the original plural text of this message or
         *  \\null\\ if there is no plural.
         */
        public abstract string get_original_plural ();

        /*
         * Gets the translated string that has the number
         *  provided by parameter.
         *
         * @param index Number of the requested translation.
         * @return The translated string.
         */
        public abstract string get_translation (int index);

        /*
         * Modifies the translated string that has the number
         *  provided by paramenter.
         *
         * @param index
         * @param translation
         */
        public void set_translation (int index,
                                    string? translation)
        {
            set_translation_impl (index, translation);

            if (translation != null)
            {
                string message_changed_state = new GLib.Settings ("org.gnome.gnomecat.Editor")
                    .get_string ("message-changed-state");

                state = message_changed_state == "fuzzy" ? MessageState.FUZZY : MessageState.TRANSLATED;
            }
            else
            {
                state = MessageState.UNTRANSLATED;
            }

            message_changed ();
        }

        public abstract void set_translation_impl (int index,
                                            string? translation);

        /**
         * Method that returns a string containing additional
         * information of this message such as context, translator
         * comments, etc.
         */
         public abstract string get_context ();

        /*
         * Method which adds a MessageTip to this message.
         *
         * @param tip Message to add.
         */
        public void add_tip (MessageTip tip)
        {
            tips.add (tip);
            this.added_tip (tip);
        }

        /*
         * Method that removes the MessageTip provided
         *  as parameter.
         *
         * @param tip Tip to be removed.
         */
        public void remove_tip (MessageTip tip)
        {
            tips.remove (tip);
            this.removed_tip (tip);
        }

        /**
         * Method that returns the tips corresponding the plural form provided as parameter.
         *
         */
        public ArrayList<MessageTip> get_tips_plural_form (int plural_form)
        {
            ArrayList<MessageTip> aux = new ArrayList<MessageTip> ();

            foreach (MessageTip t in this.tips)
            {
                if (t.plural_number == plural_form)
                    aux.add (t);
            }

            return aux;
        }
    }


    /**
     * Represents a File that stores messages to be translated.
     */
    public abstract class File : Object
    {

        /**
         * Readable name of the file that is going to be displayed
         *  on some parts of the UI.
         */
         public string name {get; protected set;}

        /*
         * Project which belongs this file or \\null\\ if there is no project.
         */
        public Project project {get; protected set; default = null;}

        /*
         * List of messages.
         */
        public ArrayList<Message> messages {get; protected set; default = null;}

        /**
         * Path to the original file.
         */
        public string path {get; protected set;}

        /**
         * Number of untranlated messages.
         */
        public int number_of_untranslated
            {
                get
                {
                    return cache_number_of_untranslated;
                }
            }

        /**
         * Number of translated messages.
         */
        public int number_of_translated
            {
                get
                {
                    return cache_number_of_translated;
                }
            }

        /**
         * Number of fuzzy messages.
         */
        public int number_of_fuzzy
            {
                get
                {
                    return cache_number_of_fuzzy;
                }
            }

        /**
         * Total number of messages.
         */
        public int number_of_messages
            {
                get
                {
                    return cache_number_of_untranslated +
                        cache_number_of_translated +
                        cache_number_of_fuzzy;
                }
            }

        public bool has_changed {get; set;}

        private int cache_number_of_untranslated;
        private int cache_number_of_fuzzy;
        private int cache_number_of_translated;


        public signal void file_changed ();

        /**
         * Simple constructor. Initializes an empty isntance.
         */
        public File ()
        {
            this.full (null, null);
        }

        /**
         * Creates a new File using the file path
         *  provided as parameter.
         */
        public File.with_file_path (string file_path)
        {
            this.full (file_path, null);
        }

        public File.with_project (Project proj)
        {
            this.full (null, proj);
        }

        public File.full (string? file_path, Project? proj)
        {
            messages = new ArrayList<Message> ();
            path = file_path;
            project = proj;

            if (path != null)
            {
                int index_last_slash = path.last_index_of_char ('/');
                name = path.substring (index_last_slash + 1);
                parse (path);
            }
        }


        /**
         * Method that adds a new message to the file.
         *
         * @param m Message to add.
         */
        public void add_message (Message m)
        {
            this.messages.add (m);

            switch (m.state)
            {
            case MessageState.TRANSLATED:
                this.cache_number_of_translated++;
                break;
            case MessageState.UNTRANSLATED:
                this.cache_number_of_untranslated++;
                break;
            case MessageState.FUZZY:
                this.cache_number_of_fuzzy++;
                break;
            }

            m.state_changed.connect (on_state_changed);

            m.message_changed.connect ((src) =>
            {
                has_changed = true;
                file_changed ();
            });
        }

        /**
         * Method that deletes a message from the file.
         *
         * @param m Message to delete.
         */
        public void remove_message (Message m)
        {
            this.messages.remove (m);

            switch (m.state) //Updates file statistics.
            {
            case MessageState.TRANSLATED:
                this.cache_number_of_translated--;
                break;
            case MessageState.UNTRANSLATED:
                this.cache_number_of_untranslated--;
                break;
            case MessageState.FUZZY:
                this.cache_number_of_fuzzy--;
                break;
            }
        }

        /**
         * Method that rebuild file statistics about number
         *  of fuzzy, translated and untranslated.
         */
        protected void rebuild_numbers_cache ()
        {
            this.cache_number_of_translated = 0;
            this.cache_number_of_fuzzy = 0;
            this.cache_number_of_untranslated = 0;

            foreach (Message m in this.messages)
            {
                switch (m.state)
                {
                case MessageState.TRANSLATED:
                    this.cache_number_of_translated++;
                    break;
                case MessageState.UNTRANSLATED:
                    this.cache_number_of_untranslated++;
                    break;
                case MessageState.FUZZY:
                    this.cache_number_of_fuzzy++;
                    break;
                }
            }
        }

        private void on_state_changed (MessageState old_state, MessageState new_state)
        {
            switch (old_state)
            {
            case MessageState.TRANSLATED:
                this.cache_number_of_translated--;
                break;
            case MessageState.UNTRANSLATED:
                this.cache_number_of_untranslated--;
                break;
            case MessageState.FUZZY:
                this.cache_number_of_fuzzy--;
                break;
            }

            switch (new_state) //Updates file statistics.
            {
            case MessageState.TRANSLATED:
                this.cache_number_of_translated++;
                break;
            case MessageState.UNTRANSLATED:
                this.cache_number_of_untranslated++;
                break;
            case MessageState.FUZZY:
                this.cache_number_of_fuzzy++;
                break;
            }
        }


        public void save (string? file_path)
        {
            save_file (file_path == null ? path : file_path);
            has_changed = false;
            file_changed ();
        }

        public virtual string? get_info (string key)
        {
            return null;
        }

        public virtual void set_info (string key, string value)
        {}

        protected abstract void save_file (string file_path);

        /**
         * Method that parses a file in order to populate
         *  this instance of File.
         */
        public abstract void parse (string path);
    }


    /**
     * Project that contains files.
     */
    public class Project : Object
    {

        /**
         * List of files of the project.
         */
        public ArrayList<File> files {get; private set;}

        private string _name;
        public string name
        {
            get
            {
                if (_name == null)
                {
                    int bar = path.last_index_of_char('/');
                    _name = path.substring (bar + 1);
                }
                return _name;
            }
        }

        public string path {get; private set;}

        public int _number_of_messages;
        public int number_of_messages
        {
            get
            {
                _number_of_messages = 0;
                foreach (File f in files)
                    _number_of_messages += f.number_of_messages;
                return _number_of_messages;
            }
        }

        public int _number_of_translated;
        public int number_of_translated
        {
            get
            {
                _number_of_translated = 0;
                foreach (File f in files)
                    _number_of_translated += f.number_of_translated;
                return _number_of_translated;
            }
        }

        public int _number_of_untranslated;
        public int number_of_untranslated
        {
            get
            {
                _number_of_untranslated = 0;
                foreach (File f in files)
                    _number_of_untranslated += f.number_of_untranslated;
                return _number_of_untranslated;
            }
        }

        public int _number_of_fuzzy;
        public int number_of_fuzzy
        {
            get
            {
                _number_of_fuzzy = 0;
                foreach (File f in files)
                    _number_of_fuzzy += f.number_of_fuzzy;
                return _number_of_fuzzy;
            }
        }

        public signal void project_changed ();
        public signal void file_added (File file);

        /**
         * Creates a new project in a directory.
         *
         * @param folder_path Path to the folder project.
         * @param name Name of the new project.
         */
        public Project (string folder_path)
        {
            path = folder_path;
            file_added.connect ((f) =>
                {
                    project_changed ();
                });
        }

    }
}
