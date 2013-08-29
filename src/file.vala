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

namespace ValaCAT.FileProject
{

    errordomain FileError
    {
        PARSER_NOT_FOUND
    }

    /*
     * Enum for the levels of Message Tips.
     */
    public enum TipLevel
    {
        INFO,
        WARNING,
        ERROR
    }


    public abstract class FileOpener
    {
        public abstract string[] extensions {get;}
        public abstract File? open_file (string path, Project? p);
    }

    /*
     * This class represents information that can be added to Messages in order
     *  to indicate that they have some failure or something that can be
     *  improved.
     */
    public class MessageTip : Object
    {

        /*
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
        public ArrayList<ValaCAT.TextTag> tags_original {get; private set;}

        /**
         * Tags that can be added to the translated string.
         */
        public ArrayList<ValaCAT.TextTag> tags_translation {get; private set;}

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
                ArrayList<ValaCAT.TextTag>? tags_original=null,
                ArrayList<ValaCAT.TextTag>? tags_translation=null)
        {
            this.name = name;
            this.description = description;
            this.level = level;
            this.tags_original = tags_original != null ? tags_original : new ArrayList<ValaCAT.TextTag> ();
            this.tags_translation = tags_translation != null ? tags_translation : new ArrayList<ValaCAT.TextTag> ();
        }
    }


    /*
     * State of a message.
     */
    public enum MessageState
    {
        TRANSLATED,
        UNTRANSLATED,
        FUZZY,
        OBSOLETE
    }


    /*
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
        public MessageState state
        {
            get;
            set;
            default = MessageState.TRANSLATED;
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
         * Signal for modified translations.
         *
         * @param modified_message The modified message.
         * @param index Index of the modified translation.
         * @param old_string Previous translation if any.
         * @param new_string New translation if any.
         */
        public signal void modified_translation (int index,
                                            string? old_string,
                                            string? new_string);

        /**
         * Signal emited when the state of a message changes.
         */
        public signal void changed_state (MessageState old_state,
                                        MessageState new_state);

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
         * Method that returns the language of this message.
         */
        public Language? get_language ()
        {
            return file.get_language ();
        }

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
         * @return The previous string or \\null\\ if there
         *  isn't previous string
         */
        public abstract void set_translation (int index,
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
        public string file_path {get; protected set;}

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


        private int cache_number_of_untranslated;
        private int cache_number_of_fuzzy;
        private int cache_number_of_translated;


        /**
         * Simple constructor. Initializes an empty isntance.
         */
        public File ()
        {
            this.full (null,null);
        }

        /**
         * Creates a new File using the file path
         *  provided as parameter.
         */
        public File.with_file_path (string file_path)
            throws FileError
        {
            this.full (file_path, null);
        }

        public File.with_project (Project proj)
        {
            this.full (null, proj);
        }

        public File.full (string? file_path, Project? proj)
        {
            this.messages = new ArrayList<Message> ();

            this.file_path = file_path;
            if (file_path != null)
                this.parse_file (file_path);

            this.project = proj;

        }


        /**
         * Method that adds a new message to the file.
         *
         * @param m Message to add.
         */
        public void add_message (Message m)
        {
            this.messages.add (m);
            this.connect_message (m);

            switch (m.state) //Updates file statistics.
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

        /**
         * Method that deletes a message from the file.
         *
         * @param m Message to delete.
         */
        public void remove_message (Message m)
        {
            this.messages.remove (m);
            this.disconnect_message (m);

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

        /**
         *
         */
        private void connect_message (Message m)
        {
            //TODO
        }

        /**
         *
         */
        private void disconnect_message (Message m)
        {
            //TODO
        }

        /**
         * Method that saves the instance of this File into
         *  a file indicated as parameter.
         */
        public abstract void save_file (string? file_path=null);

        /**
         * Method that parses a file in order to populate
         *  this instance of File.
         */
        public abstract void parse_file (string path);

        /**
         * Method that returns the number of plurals of this file.
         */
        public int number_of_plurals ()
        {
            Language? lang = this.get_language ();
            if (lang == null)
            {
                return 1;
            }
            else
            {
                return lang.get_number_of_plurals ();
            }
        }

        public abstract Language? get_language ();
    }


    /*
     * Project that contains files.
     */
    public class Project : Object
    {

        /**
         * List of files of the project.
         */
        public ArrayList<File> files {get; private set;}

        /**
         * Name of the project.
         */
        public string name {get; protected set;}


        public string path {get; private set;}

        /**
         * Creates a new project in a directory.
         *
         * @param folder_path Path to the folder project.
         * @param name Name of the new project.
         */
        public Project (string folder_path)
        {
            this.path = folder_path;
            this.scan_files ();
        }

        construct
        {
            this.files = new ArrayList<File> ();
        }


        /**
         * Explores the project directory searching compatible files and
         *  it adds them to the project.
         */
        public void scan_files ()
        {
            GLib.File dir = GLib.File.new_for_path (this.path);
            dir.query_info_async.begin("standard::type", 0, Priority.DEFAULT, null, (obj, res) => {
                try
                {
                    FileInfo info = dir.query_info_async.end (res);
                    if (info.get_file_type () == FileType.DIRECTORY)
                    {
                        this.add_files_from_dir (dir);
                    }
                }
                catch (Error e)
                {
                    stdout.printf ("Error: %s\n", e.message);
                }
            });
        }

        private void add_files_from_dir (GLib.File dir)
        {
            dir.enumerate_children_async.begin ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS,
                Priority.DEFAULT, null, (obj, res) => {

                try
                {
                    FileEnumerator enumerator = dir.enumerate_children_async.end (res);
                    FileInfo info;
                    while ((info = enumerator.next_file (null)) != null)
                    {
                        //FIXME: This doesn't work for Windows.
                        string path = dir.get_path () + "/" + info.get_attribute_byte_string ("standard::name");

                        if (info.get_file_type () == FileType.DIRECTORY)
                        {
                            this.add_files_from_dir (GLib.File.new_for_path (path));
                        }
                        else if (info.get_file_type () == FileType.REGULAR)
                        {
                            File f = ValaCAT.Application.get_default ().open_file (GLib.File.new_for_path (path));
                            if (f != null)
                                this.add_file (f);
                        }
                    }
                }
                catch (Error e)
                {
                    stdout.printf ("Error while adding files from %s: %s\n", dir.get_path (), e.message);
                }
            });

        }


        /**
         *
         */
        public void add_file (File f)
        {
            this.files.add (f);
        }


        /**
         *
         */
        private void remove_file (File f)
        {
            this.files.remove (f);
        }
    }

}
