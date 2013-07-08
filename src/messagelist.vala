
using Gtk;
using Gdl;
using ValaCAT.FileProject;

namespace ValaCAT.MessageList
{

	/**
	 * Widget that dislays the strings to be translated.
	 *	This widget can be dockable.
	 */
	[GtkTemplate (ui = "/info/aquelando/valacat/messagelist.ui")]
	public class MessageListWidget : DockItem
	{
		[GtkChild]
		private ListBox messages_list_box;

		public MessageListWidget() {}

		public void add_message (Message m)
		{
			this.messages_list_box.add(new MessageListRow(m));
		}
	}

	/**
	 *
	 */
	[GtkTemplate (ui = "/info/aquelando/valacat/messagelist.ui")]
	public class MessageListRow : ListBoxRow
	{

		/* ------------------- CONSTRUCTOR ----------------------- */

		/**
		 * Message related with this row.
		 */
		public Message message {get; private set;}

		/* ---------------- PRIVATE VARIABLES --------------------- */

		[GtkChild]
		private Image listboxrow_state_image;
		[GtkChild]
		private Gtk.Entry listboxrow_original;
		[GtkChild]
		private Gtk.Entry listboxrow_translation;
		[GtkChild]
		private Gtk.Box listboxrow_tipsbox;
		[GtkChild]
		private Image listboxrow_info_image;
		[GtkChild]
		private Image listboxrow_warning_image;
		[GtkChild]
		private Image listboxrow_error_image;


		/* ------------------- CONSTRUCTOR ----------------------- */

		/**
		 *
		 */
		public MessageListRow (Message m)
		{
			this.message = m;
			m.message_changed.connect ( (source) => {update_row();} );
			this.update_row();
		}


		/* ------------------- PRIVATE METHODS ------------------ */

		private void update_row ()
		{
 			string status_icon_name = "";
			string status_tooltip_text = "";
			int number_info_tips = 0, number_warning_tips = 0, number_error_tips = 0;

			switch (this.message.state)
			{
			case MessageState.TRANSLATED:
				status_icon_name = "";
				status_tooltip_text = "Translated"; //TODO: Add gettext.
				break;
			case MessageState.UNTRANSLATED:
				status_icon_name = "";
				status_tooltip_text = "Untraslated";
				break;
			case MessageState.FUZZY:
				status_icon_name = "";
				status_tooltip_text = "Fuzzy";
				break;
			}

			this.listboxrow_state_image.icon_name = status_icon_name;
			this.listboxrow_state_image.tooltip_text = status_tooltip_text;

			this.listboxrow_original.set_text(this.message.get_original_singular());
			this.listboxrow_translation.set_text(this.message.get_translation(0));

			foreach (MessageTip t in this.message.tips)
			{
				switch (t.level)
				{
				case TipLevel.INFO:
					number_info_tips++;
					break;
				case TipLevel.ERROR:
					number_error_tips++;
					break;
				case TipLevel.WARNING:
					number_warning_tips++;
					break;
				}
			}

			if (number_info_tips > 0)
			{
				this.listboxrow_info_image.visible = true;
				this.listboxrow_info_image.tooltip_text = "There are %i info tips.".printf(number_info_tips);
			}

			if (number_warning_tips > 0)
			{
				this.listboxrow_warning_image.visible = true;
				this.listboxrow_warning_image.tooltip_text = "There are %i warning tips.".printf(number_warning_tips);
			}

			if (number_error_tips > 0)
			{
				this.listboxrow_error_image.visible = true;
				this.listboxrow_error_image.tooltip_text = "There are %i error tips.".printf(number_error_tips);
			}
	}
}
}
