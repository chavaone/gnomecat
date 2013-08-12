
using Gtk;
using Gdl;
using ValaCAT.FileProject;

namespace ValaCAT.UI
{

	[GtkTemplate (ui = "/info/aquelando/valacat/filelist.ui")]
	public class FileListWidget : DockItem
	{
		[GtkChild]
		private ListBox file_list_box;

		public Project project {get; private set;}

		public FileListWidget()
		{
		}

		public FileListWidget.with_project (Project proj)
		{
			this ();
			this.project = proj;

			foreach (ValaCAT.FileProject.File f in this.project.files)
			{
				this.add_file (f);
			}

		}

		public void add_file (ValaCAT.FileProject.File f)
		{
			this.file_list_box.add (new FileListRow.from_file(f));
		}
	}

	[GtkTemplate (ui = "/info/aquelando/valacat/filelistrow.ui")]
	public class FileListRow : ListBoxRow
	{
		[GtkChild]
		private Gtk.Label label_file_name;
		[GtkChild]
		private Gtk.Label label_info_trans;
		[GtkChild]
		private Gtk.ProgressBar progressbar_file;


		public FileListRow (string file_name,
							int number_of_trans,
							int number_of_untrans,
							int number_of_fuzzy)
		{
			label_file_name.set_text(file_name);
			label_info_trans.set_text("%iT %iU %iF".printf(number_of_trans, number_of_untrans, number_of_fuzzy));
			float fraction = number_of_trans / (number_of_trans + number_of_fuzzy + number_of_untrans);
			progressbar_file.set_fraction (fraction);
		}

		public FileListRow.from_file (ValaCAT.FileProject.File f)
		{
			this ("f.name",
				f.number_of_translated,
				f.number_of_untranslated,
				f.number_of_fuzzy);
		}
	}
}