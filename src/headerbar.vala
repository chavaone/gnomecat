
using Gtk;


namespace ValaCAT.UI
{

	[GtkTemplate (ui = "/info/aquelando/valacat/headerbar.ui")]
	public class HeaderBar : Gtk.HeaderBar
	{

		public Window window {get; set;}


		public HeaderBar.with_window (Window? window)
		{
			this.window = window;
		}


		public HeaderBar()
		{
			this.with_window(null);
		}

		[GtkCallback]
		private void search_button_clicked (Button b)
		{
			this.window.init_search ();
		}
	}
}
