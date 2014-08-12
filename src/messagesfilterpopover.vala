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

    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/messagesfilterpopover.ui")]
    public class MessagesFilterPopover : Gtk.Popover
    {

        [GtkChild]
        Gtk.CheckButton translated;
        [GtkChild]
        Gtk.CheckButton untranslated;
        [GtkChild]
        Gtk.CheckButton fuzzy;

        public signal void filter_changed (bool translated, bool untranslated, bool fuzzy);

        [GtkCallback]
        private void on_filter_changed ()
        {
            filter_changed (translated.active, untranslated.active, fuzzy.active);
        }
    }
}