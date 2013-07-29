
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
		private ValaCAT.UI.Notebook notebook;
		//[GtkChild]
		private ValaCAT.UI.HeaderBar menubar;

		private ValaCAT.UI.SearchDialog search_dialog;


		private ValaCAT.Search.Search _search;

		public ValaCAT.Search.Search active_search {
			get {	return this._search;}
			set {	if (value == null)
						this.notebook.hide_search_widget ();
					else
						this.notebook.show_search_widget ();
					this._search = value;
			}}

		public Window ()
		{
			statusbar = new ValaCAT.UI.StatusBar();

			menubar = new ValaCAT.UI.HeaderBar();
			menubar.window = this;

			notebook = new ValaCAT.UI.Notebook();
			notebook.window = this;

			window_box.pack_start(menubar, expand=false);
			window_box.pack_start(notebook);
			window_box.pack_start(statusbar, expand=false);
		}

		public void add_tab (Tab t)
		{
			this.notebook.add_tab(t);
		}

		public Tab get_active_tab ()
		{
			return this.notebook.get_active_tab();
		}

		public void init_search ()
		{
			if (search_dialog == null)
				search_dialog = new SearchDialog (this);
			this.search_dialog.show_all();
		}
	}
}