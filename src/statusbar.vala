using Gtk;
using Gee;
using ValaCAT.Profiles;
using ValaCAT.UI;

namespace ValaCAT.UI
{

	[GtkTemplate (ui = "/info/aquelando/valacat/ui/statusbar.ui")]
	public class StatusBar : Box
	{
		[GtkChild]
		private ComboBox profile_combobox;
		[GtkChild]
		private Separator statusbar_separator1;
		[GtkChild]
		private Box file_status_box;
		[GtkChild]
		private ProgressBar progressbar_file;
		[GtkChild]
		private Label statusbar_label_file_info;
		[GtkChild]
		private Separator statusbar_separator2;
		[GtkChild]
		private Box project_status_box;
		[GtkChild]
		private ProgressBar progressbar_project;
		[GtkChild]
		private Label statusbar_label_project_info;
		[GtkChild]
		private Label statusbar_label_insert;
		private ProfilesListStore profiles;
		private int active;
		public ValaCAT.UI.Window window {get; set;}

		/**
		 * Signal emmited when a profile is selected on the Profiles ComboBox
		 */
		public signal void profile_selected (Profile p);


		/**
		 * Constructor for the StatusBar. Initializes an empty ComboBox
		 *	and it hides the information boxes.
		 */
		public StatusBar ()
		{
			this.profiles = new ProfilesListStore();
			this.profile_combobox.model = this.profiles;
			this.profile_combobox.changed.connect ( () => {
				this.profile_selected(this.profiles.get_profile_by_index(this.profile_combobox.active));
			});
		}

		/**
		 * Method that sets the profiles to show in the status bar
		 *	and the one which is enabled.
		 *
		 * @param profiles ArrayList of profiles to show.
		 * @param enabled_profile Index in the previous ArrayList
		 *	of the selected profile.
		 */
		public void set_profiles (ArrayList<Profile> profiles, int enabled_profile)
		{
			this.profiles.set_profiles(profiles);
			this.active = enabled_profile;
		}

		/**
		 * Method that hides the file information box.
		 */
		public void hide_file_info ()
		{
			this.file_status_box.hide();
			this.statusbar_separator1.hide();
		}

		/**
		 * Method that hides the project information box.
		 */
		public void hide_project_info ()
		{
			this.project_status_box.hide();
			this.statusbar_separator2.hide();
		}

		/**
		 * Method that sets the data showed on the file information box.
		 *
		 * @param translated Number of translated messages.
		 * @param untranslated Number of untranslated messages.
		 * @param fuzzy Number of fuzzy messages.
		 */
		public void set_file_info (int translated, int untranslated, int fuzzy)
		{
			this.statusbar_label_file_info.set_text("%iT + %iU + %iF".printf(translated,untranslated,fuzzy));
			double total = translated + untranslated + fuzzy;
			this.progressbar_file.fraction = translated / total;
			this.file_status_box.show_all();
			this.statusbar_separator1.show();
		}

		/**
		 * Method that sets the data showed on the project information box.
		 *
		 * @param translated Number of translated messages.
		 * @param untranslated Number of untranslated messages.
		 * @param fuzzy Number of fuzzy messages.
		 */
		public void set_project_info (int translated, int untranslated, int fuzzy)
		{
			this.statusbar_label_project_info.set_text("%iT + %iU + %iF".printf(translated,untranslated,fuzzy));
			this.progressbar_project.fraction = translated / (translated + untranslated + fuzzy);
			this.project_status_box.show_all();
			this.statusbar_separator2.show();
		}

		/**
		 * Method that sets the writing mode indicator to
		 *	INS in the StatusBar.
		 */
		public void set_insertion_mode ()
		{
			this.statusbar_label_insert.set_text("INS"); //TODO: add gettext
		}

		/**
		 * Method that sets the writing mode indicator to
		 *	OVR in the StatusBar.
		 */
		public void set_overwrite_mode ()
		{
			this.statusbar_label_insert.set_text("OVR");
		}
	}

	public class ProfilesListStore : ListStore
	{

		private ArrayList<Profile> profiles;

		/**
		 * Initializes an empty ListStore;
		 */
		public ProfilesListStore ()
		{
			this.with_profiles(new ArrayList<Profile>());
		}

		/**
		 * Initializes a ListStore with the profiles provided as parameter.
		 */
		public ProfilesListStore.with_profiles (ArrayList<Profile> profiles)
		{
			this.profiles = profiles;
			this.set_profiles(profiles);
		}

		/**
		 * Method that updates the data of the ListStore.
		 */
		public void set_profiles (ArrayList<Profile> profiles_list)
		{
			Gtk.TreeIter iter;

			this.clear();

			foreach (Profile p in profiles_list)
			{
				this.append(out iter);
				this.set(iter,0,p.name);
			}
		}

		/**
		 * Method that returns the profile that is in the
		 *	position provided by the index.
		 */
		public Profile get_profile_by_index (int index)
		{
			return profiles.get(index);
		}
	}
}
