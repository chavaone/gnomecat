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

    public enum SelectLevel
    {
        FILE,
        ROW,
        PLURAL,
        STRING
    }


    public class TextTag : Object
    {

        public Gtk.TextTag tag {get; private set;}
        public int ini_offset {get; private set;}
        public int end_offset {get; private set;}

        public TextTag (Gtk.TextTag tag)
        {
            this.with_range (tag, -1, -1);
        }

        public TextTag.with_range (Gtk.TextTag tag, int ini_offset, int end_offset)
        {
            this.tag = tag;
            this.ini_offset = ini_offset;
            this.end_offset = end_offset;
        }

        public TextTag.from_message_fragment (MessageFragment mf, string tag_name)
        {
            tag = new Gtk.TextTag (tag_name);

            Gdk.RGBA color_background = Gdk.RGBA ();
            color_background.parse ("#ABBAE3");
            tag.background_rgba = color_background;
            tag.background_set = true;

            Gdk.RGBA color_foreground = Gdk.RGBA ();
            color_foreground.parse ("white");
            tag.foreground_rgba = color_foreground;
            tag.foreground_set = true;

            tag.weight = Pango.Weight.BOLD;
            tag.weight_set = true;
            this.ini_offset = mf.index;
            this.end_offset = mf.index + mf.length;
        }
    }
}