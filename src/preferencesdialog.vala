

namespace ValaCAT.UI
{

    [GtkTemplate (ui = "/info/aquelando/valacat/ui/preferencesdialog.ui")]
	public class PreferencesDialog : Gtk.Dialog
	{
		private Settings settings;

		[GtkChild]
		private Gtk.CheckButton highlight_checkbutton;
		[GtkChild]
		private Gtk.CheckButton visible_whitespace_checkbutton;
		[GtkChild]
		private Gtk.CheckButton use_custom_font_checkbutton;
		[GtkChild]
		private Gtk.FontButton editor_font_fontbutton;
		[GtkChild]
		private Gtk.Box editor_font_hbox;
		[GtkChild]
		private Gtk.ComboBoxText changed_state;

		public PreferencesDialog ()
		{
			settings = new Settings ("info.aquelando.valacat");

			highlight_checkbutton.active = settings.get_boolean ("highlight");
			visible_whitespace_checkbutton.active = settings.get_boolean ("visible-whitespace");
			editor_font_fontbutton.font = settings.get_string ("font");
			editor_font_hbox.sensitive = settings.get_boolean ("custom-font");
			changed_state.active_id = settings.get_string ("message-changed-state");

			settings.bind ("highlight", highlight_checkbutton, "active",  SettingsBindFlags.DEFAULT);
			settings.bind ("visible-whitespace", visible_whitespace_checkbutton, "active",  SettingsBindFlags.DEFAULT);
			settings.bind ("font", editor_font_fontbutton, "font", SettingsBindFlags.DEFAULT);
			settings.bind ("custom-font", use_custom_font_checkbutton, "active", SettingsBindFlags.DEFAULT);
			settings.bind ("custom-font", editor_font_hbox, "sensitive", SettingsBindFlags.DEFAULT);
			settings.bind ("message-changed-state", changed_state, "active_id", SettingsBindFlags.DEFAULT);
		}
	}
}