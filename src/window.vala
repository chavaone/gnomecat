
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

		public signal void file_changed (ValaCAT.FileProject.File? file);
		public signal void project_changed (ValaCAT.FileProject.Project? project);

		public Window ()
		{
			statusbar = new ValaCAT.UI.StatusBar();
			statusbar.window = this;

			menubar = new ValaCAT.UI.HeaderBar();
			menubar.window = this;

			notebook = new ValaCAT.UI.Notebook();
			notebook.window = this;

			window_box.pack_start(menubar, expand=false);
			window_box.pack_start(notebook);
			window_box.pack_start(statusbar, expand=false);

			this.file_changed.connect(on_file_changed);
			this.project_changed.connect(on_project_changed);
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

		public void on_file_changed (Window src, ValaCAT.FileProject.File? file)
		{
			if (file == null)
				this.statusbar.hide_file_info ();
			else
				this.statusbar.set_file_info (file.number_of_translated,
					file.number_of_untranslated,
					file.number_of_fuzzy);
		}

		public void on_project_changed (Window src, ValaCAT.FileProject.Project? project)
		{
			if (project == null)
				this.statusbar.hide_project_info ();
			/*else
				this.statusbar.set_project_info (project.number_of_translated,
					project.number_of_untranslated,
					project.number_of_fuzzy);
			*/ //TODO: Add project counters.
		}
	}
}