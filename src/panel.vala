

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

		public virtual void on_edit_undo (GNOMECAT.UI.Window window) {}

		public virtual void on_edit_redo (GNOMECAT.UI.Window window) {}

		public virtual void on_search_next (GNOMECAT.UI.Window window) {}

		public virtual void on_search_previous (GNOMECAT.UI.Window window) {}

		public virtual void on_search_replace (GNOMECAT.UI.Window window) {}

		public virtual void on_open_file (GNOMECAT.UI.Window window) {}

		public virtual void on_done (GNOMECAT.UI.Window window) {}

		public virtual void on_back (GNOMECAT.UI.Window window) {}

		public virtual void on_search (GNOMECAT.UI.Window window) {}

		public virtual void on_preferences (GNOMECAT.UI.Window window)
		{
			window.set_panel (WindowStatus.PREFERENCES);
		}
	}
}