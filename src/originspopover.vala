/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of GNOMECAT
 *
 * Copyright (C) 2014 - Marcos Chavarría Teijeiro
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

namespace GNOMECAT.UI
{


    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/originspopover.ui")]
    public class OriginsPopover : Gtk.Popover
    {

        [GtkChild]
        Gtk.ListBox origins;

        private GNOMECAT.Message _message;
        public GNOMECAT.Message message
        {
            get
            {
                return _message;
            }

            set
            {
                _message = value;
                origins.foreach ( (w) => {origins.remove(w);});
                foreach (var x in value.origins)
                {
                    origins.add (new OriginRow (x.file, x.line));
                }
            }
        }
    }

    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/originsrow.ui")]
    public class OriginRow : Gtk.ListBoxRow
    {
        [GtkChild]
        Gtk.Label file;

        [GtkChild]
        Gtk.Label number;


        public OriginRow (string file, size_t number)
        {
            this.file.label = file;
            this.number.label = "%zu".printf (number);
        }
    }
}