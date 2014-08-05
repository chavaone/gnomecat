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
using GNOMECAT.Iterators;
using GNOMECAT.UI;

namespace GNOMECAT.Navigator
{
    public class FileNavigator : Navigator
    {

        private CheckMessageFunction check_function;
        private Gtk.TreeSelection selection;

        public FileNavigator (GNOMECAT.UI.EditPanel edit_panel,
            CheckMessageFunction check_function)
        {
            this.selection = edit_panel.message_list.selection;
            this.check_function = check_function;
        }

        public override bool next ()
        {

            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            GNOMECAT.Message curr_msg;

            if (! selection.get_selected (out model, out iter)) first ();

            if (! model.iter_next (ref iter)) return false;

            do {

                model.get (iter, 0, out curr_msg);
                if (check_function (curr_msg))
                {
                    selection.select_iter (iter);
                    return true;
                }

            } while (model.iter_next (ref iter));

            return false;
        }

        public override bool previous ()
        {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            GNOMECAT.Message curr_msg;

            if (! selection.get_selected (out model, out iter)) last ();

            if (! model.iter_previous (ref iter)) return false;

            do {

                model.get (iter, 0, out curr_msg);
                if (check_function (curr_msg))
                {
                    selection.select_iter (iter);
                    return true;
                }

            } while (model.iter_previous (ref iter));

            return false;
        }

        public override bool first ()
        {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            GNOMECAT.Message curr_msg;

            if (! selection.get_selected (out model, out iter)) last ();

            if (! model.get_iter_first (out iter)) return false;

            do {

                model.get (iter, 0, out curr_msg);
                if (check_function (curr_msg))
                {
                    selection.select_iter (iter);
                    return true;
                }

            } while (model.iter_next (ref iter));

            return false;
        }

        public override bool last ()
        {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            GNOMECAT.Message curr_msg;

            while (next ());

            if (! selection.get_selected (out model, out iter)) last ();

            if (! model.iter_previous (ref iter)) return false;

            do {

                model.get (iter, 0, out curr_msg);
                if (check_function (curr_msg))
                {
                    selection.select_iter (iter);
                    return true;
                }

            } while (model.iter_previous (ref iter));

            return false;
        }
    }
}