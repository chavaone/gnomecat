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

	public class FirstProfilePanel : GNOMECAT.UI.SimpleProfilePanel
	{

        public override void on_done (GNOMECAT.UI.Window window)
        {
        	base.on_done(window);
        	window.set_panel(WindowStatus.OPENEDFILES);
            window.window_panels.remove_page (window_page);
        }

        public override void setup_headerbar (GNOMECAT.UI.ToolBar toolbar)
        {
            base.setup_headerbar (toolbar);
            toolbar.back_btn.visible = false;
        }

	}

}