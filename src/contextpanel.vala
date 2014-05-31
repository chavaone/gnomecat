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

using Gtk;
using GNOMECAT.FileProject;

namespace GNOMECAT.UI
{
    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/contextpanel.ui")]
    public class ContextPanel : Gtk.Box, ChangedMessageSensible
    {
        [GtkChild]
        private TextView context_textview;

        private Message _message;
        public Message message
        {
            get
            {
                return _message;
            }
            set
            {
                _message = value;
                context_textview.buffer.text = value == null ? "" :
                    value.get_context ();
            }
        }
    }
}