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

using Gtk;
using Gdl;
using ValaCAT.FileProject;

namespace ValaCAT.UI
{

    [GtkTemplate (ui = "/info/aquelando/valacat/ui/contextpanel.ui")]
    public class ContextPanel : DockItem, ChangedMessageSensible
    {
        [GtkChild]
        private TextView context_textview;

        public ContextPanel () {}

        public void set_message (Message m)
        {
            this.context_textview.buffer.text = m == null ? "" : m.get_context();
        }
    }
}