

using Gdl;
using Gtk;
using ValaCAT.FileProject;


namespace ValaCAT.UI
{
	/**
	 * Generic tab.
	 */
	[GtkTemplate (ui = "/info/aquelando/valacat/tab.ui")]
	public abstract class Tab : Box
	{
		public Label label {get; protected set;}
		public abstract ValaCAT.FileProject.File? file {get;}
		public abstract ValaCAT.FileProject.Project? project {get;}

		[GtkChild]
		private Gdl.Dock dock;
		[GtkChild]
		private Gdl.DockBar dockbar;
		private DockLayout layout_manager;

		public Tab ()
		{
			this.dockbar.master = dock;
			this.layout_manager = new DockLayout(dock);
		}

		public void load_layout (string file)
		{
			this.layout_manager.load_from_file(file);
		}

		public void save_layout (string file)
		{
			this.layout_manager.save_to_file(file);
		}

		public void add_item (DockItem item, DockPlacement place)
		{
			this.dock.add_item(item,place);
		}

	}

	public class FileTab : Tab
	{
		public MessageListWidget message_list {get; private set;}
		public MessageEditorWidget message_editor {get; private set;}
		public ContextPanel context_pannel {get; private set;}

		public override ValaCAT.FileProject.File? file {get {return this._file;}}
		public override ValaCAT.FileProject.Project? project {get {return this._file != null ? this._file.project : null;}}

		private ValaCAT.FileProject.File? _file;

		public FileTab (ValaCAT.FileProject.File? f)
		{
			base();
			this.label = new Gtk.Label("filename"); //TODO f.name;
			this._file = f;
			this.message_list = new MessageListWidget();
			foreach (Message m in f.messages)
			{
				this.message_list.add_message(m);
			}
			this.add_item(this.message_list, DockPlacement.CENTER);

			this.message_editor = new MessageEditorWidget();
			this.message_editor.set_message(f.messages.get(0));
			this.add_item(this.message_editor, DockPlacement.BOTTOM);

			this.context_pannel = new ContextPanel();
			this.context_pannel.set_message(f.messages.get(0));
			this.add_item(this.context_pannel,DockPlacement.RIGHT);

			this.message_list.message_selected.connect ( (source, message) => {
				this.context_pannel.set_message(message);
				this.message_editor.set_message(message);
				});
		}
	}

	public class ProjectTab : Tab
	{
		public override ValaCAT.FileProject.File? file {get {return null;}}
		public override ValaCAT.FileProject.Project? project {get {return this._project;}}

		private FileListWidget file_list;

		private ValaCAT.FileProject.Project? _project;

		public ProjectTab (Project p)
		{
			base();
			this.label = new Gtk.Label ("projectname"); //TODO project.name
			this._project = p;

			this.file_list = new FileListWidget.with_project (p);
			this.add_item(this.file_list, DockPlacement.CENTER);
		}
	}
}
