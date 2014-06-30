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

    public enum ToolBarMode
    {
        EDIT = 0,
        OPENEDFILES = 1,
        COMPLETE = 2
    }

    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/toolbar.ui")]
    public class ToolBar : Gtk.Notebook
    {

        [GtkChild]
        public Gtk.ProgressBar progressbar_title;
        [GtkChild]
        public Gtk.ToggleButton searchbutton;
        [GtkChild]
        public Gtk.StackSwitcher stack_switch;
        [GtkChild]
        public Gtk.Button done_btn;
        [GtkChild]
        public Gtk.Button back_btn;
        [GtkChild]
        public Gtk.Image edit_bar_save_back_img;

        public ToolBarMode mode
        {
            get
            {
                switch (page)
                {
                case 0:
                    return ToolBarMode.EDIT;
                case 1:
                    return ToolBarMode.OPENEDFILES;
                case 2:
                    return ToolBarMode.COMPLETE;
                default:
                    return ToolBarMode.COMPLETE;
                }
            }
            set
            {
                page = value;
            }
        }

        public void on_file_changed (GNOMECAT.FileProject.File? file)
        {
            if (file == null)
            {
                progressbar_title.hide ();
                return;
            }

            progressbar_title.show ();
            progressbar_title.set_text (_("%iT + %iU + %iF").printf (file.number_of_translated,
                file.number_of_untranslated, file.number_of_fuzzy));
            double total = file.number_of_translated + file.number_of_untranslated + file.number_of_fuzzy;
            progressbar_title.fraction = file.number_of_translated / total;

            edit_bar_save_back_img.icon_name = file.has_changed ? "document-save-symbolic" : "go-previous-symbolic";
        }

    }

}