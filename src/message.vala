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


    /**
     * Origin of each message provided as file name and line number.
     */
    public class MessageOrigin : Object
    {
        public string file {get; set construct;}
        public size_t line {get; set construct;}

        public MessageOrigin (string file, size_t line)
        {
            Object (file:file, line:line);
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

        /**
         * List of origins of the message.
         */
        public abstract ArrayList<GNOMECAT.MessageOrigin> origins
        {
            get;
        }

        /*
         * List of tips that this message has.
         */
        public ArrayList<GNOMECAT.MessageTip> tips {get; private set; default = null;}

        /**
         * Indicates the order of this message inside its file.
         */
        public int natural_order_value {get; set;}

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
        public signal void added_tip (GNOMECAT.MessageTip tip);

        /**
         * Signal emited when a new tip is deleted from this message.
         *
         * @param tip Deleted tip.
         */
        public signal void removed_tip (GNOMECAT.MessageTip tip);

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

        /**
         * Actual implementation of set_translation.
         */
        protected abstract void set_translation_impl (int index,
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
        public void add_tip (GNOMECAT.MessageTip tip)
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
        public void remove_tip (GNOMECAT.MessageTip tip)
        {
            tips.remove (tip);
            this.removed_tip (tip);
        }

        /**
         * Method that returns the tips corresponding the plural form provided as parameter.
         *
         */
        public ArrayList<GNOMECAT.MessageTip> get_tips_plural_form (int plural_form)
        {
            ArrayList<GNOMECAT.MessageTip> aux = new ArrayList<MessageTip> ();

            foreach (GNOMECAT.MessageTip t in this.tips)
            {
                if (t.plural_number == plural_form)
                    aux.add (t);
            }

            return aux;
        }
    }
}