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
        public int number_of_untranslated {get; protected set; default = 0;}

        /**
         * Number of translated messages.
         */
        public int number_of_translated {get; protected set; default = 0;}

        /**
         * Number of fuzzy messages.
         */
        public int number_of_fuzzy {get; protected set; default = 0;}

        /**
         * Total number of messages.
         */
        public int number_of_messages
            {
                get
                {
                    return number_of_untranslated +
                        number_of_translated +
                        number_of_fuzzy;
                }
            }

        /**
         * Indicates if the file has changed.
         */
        public bool has_changed {get; set;}

        /**
         * Signal emmited when the file has changed.
         */
        public signal void file_changed ();

        /**
         * Simple constructor. Initializes an empty instance.
         */
        public File ()
        {
            this.full (null, null);
        }

        /**
         * Constructor providing file path.
         */
        public File.with_file_path (string file_path)
        {
            this.full (file_path, null);
        }

        /**
         * Constructor providing file path and project.
         */
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
                this.number_of_translated++;
                break;
            case MessageState.UNTRANSLATED:
                this.number_of_untranslated++;
                break;
            case MessageState.FUZZY:
                this.number_of_fuzzy++;
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
                this.number_of_translated--;
                break;
            case MessageState.UNTRANSLATED:
                this.number_of_untranslated--;
                break;
            case MessageState.FUZZY:
                this.number_of_fuzzy--;
                break;
            }
        }

        /**
         * Saves a file in the path provided by parameter.
         */
        public void save (string? file_path)
        {
            save_file (file_path == null ? path : file_path);
            has_changed = false;
            file_changed ();
        }

        /**
         * Method that parses a file in order to populate
         *  this instance of File.
         * @parameter path Path of the file to parse.
         */
        public abstract void parse (string path);

        /**
         * Provides info about file. It works as a key-value map.
         * This is the default implementation that always returns null.
         *
         * @param key
         */
        public virtual string? get_info (string key)
        {
            return null;
        }

        /**
         * Sets info about a file. It works as a key-value map.
         * This is the default implementation that does nothing.
         *
         * @param key
         * @param value
         */
        public virtual void set_info (string key, string value)
        {}

        /**
         * Actual implementation of save files.
         *
         * @param file_path
         */
        protected abstract void save_file (string file_path);

        /**
         * Handler for message state changed signal.
         * It updates the file statistics.
         *
         * @param old_state
         * @param new_state
         */
        private void on_state_changed (MessageState old_state, MessageState new_state)
        {
            switch (old_state)
            {
            case MessageState.TRANSLATED:
                this.number_of_translated--;
                break;
            case MessageState.UNTRANSLATED:
                this.number_of_untranslated--;
                break;
            case MessageState.FUZZY:
                this.number_of_fuzzy--;
                break;
            }

            switch (new_state)
            {
            case MessageState.TRANSLATED:
                this.number_of_translated++;
                break;
            case MessageState.UNTRANSLATED:
                this.number_of_untranslated++;
                break;
            case MessageState.FUZZY:
                this.number_of_fuzzy++;
                break;
            }
        }
    }
}
