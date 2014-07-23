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

namespace GNOMECAT
{

    public abstract class Checker : Peas.ExtensionBase,  Peas.Activatable
    {
        public Object object  { owned get; construct; }

        public void activate ()
        {
            (object as GNOMECAT.API).check_message.connect (on_check_message);
        }

        public void deactivate ()
        {
            (object as GNOMECAT.API).check_message.disconnect (on_check_message);
        }

        public void update_state ()
        {
        }

        protected abstract void on_check_message (GNOMECAT.Message m);
    }


    public abstract class HintProvider : Peas.ExtensionBase,  Peas.Activatable
    {
        public Object object  { owned get; construct; }


        public void activate ()
        {
            (object as GNOMECAT.API).provide_hints.connect (on_provide_hints);
        }

        public void deactivate ()
        {
            (object as GNOMECAT.API).provide_hints.disconnect (on_provide_hints);
        }

        public void update_state ()
        {
        }

        protected abstract void on_provide_hints (GNOMECAT.Message m, GNOMECAT.HintViewer hv);
    }

}