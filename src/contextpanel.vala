

using Gtk;
using Gdl;
using ValaCAT.FileProject;

namespace ValaCAT.UI
{

	[GtkTemplate (ui = "/info/aquelando/valacat/ui/contextpanel.ui")]
	public class ContextPanel : DockItem, ChangedMessageSensible
	{
		[GtkChild]
		private TextView context_textview;

		public ContextPanel () {}

		public void set_message (Message m)
		{
			this.context_textview.buffer.text = m == null ? "" : m.get_context();
		}
	}
}