
using Gtk;
using ValaCAT.Search;

namespace ValaCAT.UI
{
	[GtkTemplate (ui = "/info/aquelando/valacat/window.ui")]
	public class Window : Gtk.Window
	{
		[GtkChild]
		private Gtk.Box window_box;
		//[GtkChild]
		private ValaCAT.UI.StatusBar statusbar;
		//[GtkChild]
		private Gtk.Notebook notebook;
		//[GtkChild]
		private ValaCAT.UI.HeaderBar menubar;

		public ValaCAT.Search.Search active_search;

		public Window ()
		{
			statusbar = new ValaCAT.UI.StatusBar();
			menubar = new ValaCAT.UI.HeaderBar();
			notebook = new Gtk.Notebook();
			window_box.pack_start(menubar, expand=false);
			window_box.pack_start(notebook);
			window_box.pack_start(statusbar, expand=false);
		}

		public void add_tab (Tab t)
		{
			this.notebook.append_page(t,t.label);
		}

		public Tab get_active_tab ()
		{
			int page_number = this.notebook.get_current_page ();
			return this.notebook.get_nth_page(page_number) as Tab;
		}
	}
}