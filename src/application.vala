


using Gtk;
using ValaCAT.UI;

namespace ValaCAT.Application
{
	public class Application : Gtk.Application
	{

		private Application ()
		{
			Object (application_id: "info.aquelando.valacat",
				flags: ApplicationFlags.HANDLES_OPEN);
		}

		public override void activate ()
		{
			ValaCAT.UI.Window window = new ValaCAT.UI.Window (this);
			window.present ();
			Gtk.main ();
		}

		public override void open (File[] files, string hint)
		{
			ValaCAT.UI.Window window = new ValaCAT.UI.Window (this);

			foreach (File f in files)
			{
				window.add_tab (new FileTab(new ValaCAT.Demo.DemoFile ()));
			}

			window.present ();
			Gtk.main ();
		}

		public static int main (string[] args)
		{
			Application app = new Application ();
			return app.run (args);
		}

	}
}