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

namespace GNOMECAT.UI
{

    [GtkTemplate (ui = "/info/aquelando/gnomecat/ui/toolbar.ui")]
    public class ToolBar : Gtk.Notebook
    {

    	[GtkChild]
        public Gtk.Label edit_label_title;
        [GtkChild]
        public Gtk.ProgressBar progressbar_title;
        [GtkChild]
        public Gtk.StackSwitcher preferences_switch;

        public void set_edit_toolbar(){
            this.page = 0;
        }

        public void set_doneback_toolbar(){
            this.page = 2;
        }

        public void set_preferences_toolbar(){
            this.page = 1;
        }

        public void set_back_toolbar(){
            this.page = 3;
        }

        public void set_progressbar_info (int translated, int untranslated, int fuzzy)
        {
                progressbar_title.show ();
                progressbar_title.set_text (_("%iT + %iU + %iF").printf (translated,
                    untranslated, fuzzy));
                double total = translated + untranslated + fuzzy;
                progressbar_title.fraction = translated / total;
        }

    }

}