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
    public class Hint : Object
    {
        public string translation_hint {get; private set;}
        public string origin {get; private set;}
        public double accuracy {get; private set;}

        public Hint (string translation_hint,
                    string origin,
                    double accuracy)
        {
            this.origin = origin;
            this.translation_hint = translation_hint;
            this.accuracy = accuracy;
        }
    }

    public abstract class HintProvider : Object
    {
        public abstract void get_hints (GNOMECAT.FileProject.Message m, GNOMECAT.UI.HintPanelWidget hpw);
    }
}