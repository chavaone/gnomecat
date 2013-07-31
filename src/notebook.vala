

using Gtk;

namespace ValaCAT.UI
{

	[GtkTemplate (ui = "/info/aquelando/valacat/notebook.ui")]
	public class Notebook : Gtk.Overlay
	{
		[GtkChild]
		private Gtk.Notebook notebook;
		[GtkChild]
		private Gtk.Revealer search_slider;
		[GtkChild]
		private Gtk.Entry search_entry;

		public ValaCAT.UI.Window window {get; set;}


		public void hide_search_widget ()
		{
			this.search_slider.set_reveal_child (false);
		}

		public void show_search_widget ()
		{
			print("SHOW search widget");
			this.search_slider.show_all();
			this.search_slider.set_reveal_child (true);
		}

		public void add_tab (Tab t)
		{
			this.notebook.append_page (t, t.label);
		}

		public Tab get_active_tab ()
		{
			int page_number = this.notebook.get_current_page ();
			return this.notebook.get_nth_page (page_number) as Tab;
		}

		[GtkCallback]
		private void search_bar_next (Button b)
		{
			this.window.active_search.next_item();
		}

		[GtkCallback]
		private void search_bar_previous (Button b)
		{
			this.window.active_search.previous_item();
		}

		[GtkCallback]
		private void on_switch_page (Gtk.Widget src,
									uint page)
		{
			int page_num = int.parse(page.to_string());
			Tab t = this.notebook.get_nth_page (page_num) as Tab;
			this.window.file_changed (t.file);
			this.window.project_changed (t.project);
		}

	}
}
