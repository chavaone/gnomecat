

using Gtk;
using Gdl;

namespace ValaCAT.ContextPanel
{

	[GtkTemplate (ui = "/info/aquelando/valacat/contextpanel.ui")]
	public class ContextPanel : DockItem, ChangedMessageSensible
	{
		[GtkChild]
		private TextView context_textview;

		public DockItem () {}

		public override void set_message (Message m)
		{
			this.context_textview.buffer.text = m == null ? "" : m.get_context();
		}
	}
}