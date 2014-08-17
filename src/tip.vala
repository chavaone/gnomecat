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

}