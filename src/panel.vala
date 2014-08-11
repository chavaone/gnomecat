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
	public interface Panel : GLib.Object
	{

		public abstract GNOMECAT.UI.ToolBarMode toolbarmode {get;}

		public abstract int window_page {get; set;}

		public virtual void setup_headerbar (GNOMECAT.UI.ToolBar toolbar)
		{
			toolbar.mode = toolbarmode;
		}

		public virtual void clean_headerbar (GNOMECAT.UI.ToolBar toolbar) {}

		public virtual void on_go_next (GNOMECAT.UI.Window window) {}

		public virtual void on_go_previous (GNOMECAT.UI.Window window) {}

		public virtual void on_go_next_fuzzy (GNOMECAT.UI.Window window) {}

		public virtual void on_go_previous_fuzzy (GNOMECAT.UI.Window window) {}

		public virtual void on_go_next_translated (GNOMECAT.UI.Window window) {}

		public virtual void on_go_previous_translated (GNOMECAT.UI.Window window) {}

		public virtual void on_go_next_untranslated (GNOMECAT.UI.Window window) {}

		public virtual void on_go_previous_untranslated (GNOMECAT.UI.Window window) {}

		public virtual void on_edit_save_back (GNOMECAT.UI.Window window) {}

		public virtual void on_edit_save (GNOMECAT.UI.Window window) {}

		public virtual void on_edit_undo (GNOMECAT.UI.Window window) {}

		public virtual void on_edit_redo (GNOMECAT.UI.Window window) {}

		public virtual void on_search_next (GNOMECAT.UI.Window window) {}

		public virtual void on_search_previous (GNOMECAT.UI.Window window) {}

		public virtual void on_search_replace (GNOMECAT.UI.Window window) {}

		public virtual void on_open_file (GNOMECAT.UI.Window window) {}

		public virtual void on_done (GNOMECAT.UI.Window window) {}

		public virtual void on_back (GNOMECAT.UI.Window window) {}

		public virtual void on_search (GNOMECAT.UI.Window window) {}

		public virtual void on_change_state (GNOMECAT.UI.Window window) {}

		public virtual void on_preferences (GNOMECAT.UI.Window window)
		{
			window.set_panel (WindowStatus.PREFERENCES);
		}

		public virtual void on_hint (GNOMECAT.UI.Window window, int num) {}
	}
}