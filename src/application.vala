


using Gtk;
using ValaCAT.UI;
using ValaCAT.FileProject;

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
			window.show_all ();
			Gtk.main ();
		}

		public override void open (GLib.File[] files, string hint)
		{
			ValaCAT.UI.Window window = new ValaCAT.UI.Window (this);

			foreach (GLib.File f in files)
			{
				window.add_tab (new FileTab(new ValaCAT.Demo.DemoFile ()));
			}

			ValaCAT.FileProject.Project p = new Project ("");

			p.add_file (new ValaCAT.Demo.DemoFile ());
			p.add_file (new ValaCAT.Demo.DemoFile ());

			window.add_tab (new ProjectTab(p));

			window.show_all ();
			Gtk.main ();
		}

		public static int main (string[] args)
		{
			/*Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
    		Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
    		Intl.textdomain (Config.GETTEXT_PACKAGE);
			*/

			var app = new Application ();
			return app.run (args);
		}

	}
}