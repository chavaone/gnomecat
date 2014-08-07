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
     * Project that contains files.
     */
    public class Project : Object
    {
        /**
         * List of files of the project.
         */
        public ArrayList<GNOMECAT.File> files {get; private set;}

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
                foreach (GNOMECAT.File f in files)
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
                foreach (GNOMECAT.File f in files)
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
                foreach (GNOMECAT.File f in files)
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
                foreach (GNOMECAT.File f in files)
                    _number_of_fuzzy += f.number_of_fuzzy;
                return _number_of_fuzzy;
            }
        }

        public signal void project_changed ();
        public signal void file_added (GNOMECAT.File file);

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