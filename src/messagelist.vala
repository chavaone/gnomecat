
using Gtk;

namespace ValaCAT.MessageList
{

	/**
	 * Widget that dislays the strings to be translated.
	 *	This widget can be dockable.
	 */
	[GtkTemplate (ui = "/info/aquelando/valacat/messagelistrow.ui")]
	public class MessageListWidget : DockItem
	{
		[GtkChild]
		private ListBox messages_list_box;

		public MessageList() {}

		public void add_message (MesageListRow field)
		{
			this.messages_list_box.add(field);
		}
	}

	/**
	 *
	 */
	[GtkTemplate (ui = "/info/aquelando/valacat/messagelistrow.ui")]
	public class MesageListRow : ListBoxRow
	{
		[GtkChild]
		private Gtk.Entry listboxrow_original;
		[GtkChild]
		private Gtk.Entry listboxrow_translation;
		[GtkChild]
		private Gtk.Box listboxrow_tipsbox;

		public MessageListRow (string original, string translation)
		{
			this.listboxrow_original.set_text(original);
			this.listboxrow_translation.set_text(translation);
		}
	}
}