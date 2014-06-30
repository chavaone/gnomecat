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

    [GtkTemplate (ui = "/org/gnome/gnomecat/ui/pofilerow.ui")]
    public class PoFileRow : Gtk.ListBoxRow
    {
        [GtkChild]
        private Gtk.Label file_name;
        [GtkChild]
        private Gtk.Label language;
        [GtkChild]
        private Gtk.Label file_path;
        [GtkChild]
        private Gtk.ProgressBar progress;

        private GNOMECAT.PoFiles.PoFile _file;
        public GNOMECAT.PoFiles.PoFile file
        {
            get
            {
                return _file;
            }
            private set
            {
                _file = value;

                file_name.set_text (_file.get_info ("Project-Id-Version"));
                file_path.set_text (_file.path);
                language.set_text ("(%s)".printf (_file.get_info ("Language")));

                double total = _file.number_of_translated + _file.number_of_untranslated
                    + _file.number_of_fuzzy;
                progress.fraction = _file.number_of_translated / total;
                progress.text = "%iT %iU %iF".printf (_file.number_of_translated,
                    _file.number_of_untranslated, _file.number_of_fuzzy);
            }
        }

        public PoFileRow (GNOMECAT.PoFiles.PoFile f)
        {
            file = f;
        }
    }
}