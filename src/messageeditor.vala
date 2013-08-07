using Gdl;
using Gtk;
using ValaCAT.FileProject;
using Gee;

namespace ValaCAT.UI
{

	/**
	 * Editing pannel widget.
	 */
	[GtkTemplate (ui = "/info/aquelando/valacat/messageeditor.ui")]
	public class MessageEditorWidget : DockItem, ChangedMessageSensible
	{
		[GtkChild]
		private Gtk.Notebook plurals_notebook;
		private Message message;

		public MessageEditorWidget ()
		{}

		public void set_message (Message m)
		{
			int i;
			this.clean_tabs();
			//TODO: Add gettext integration.
			string label = "Singular (%s)".printf(m.get_language().get_plural_form_tag(0));
			var auxtab = new MessageEditorTab(label, m, 0);
			foreach (MessageTip t in m.get_tips_plural_form(0))
				auxtab.add_tip(t);
			this.add_tab(auxtab);

			if ( m.has_plural() )
			{
				int num_plurals = m.get_language().get_number_of_plurals();
				for(i = 1; i < num_plurals; i++)
				{
					label = "Plural %i (%s)".printf(i,m.get_language().get_plural_form_tag(i)); //TODO: add language plural tags and gettext.
					auxtab = new MessageEditorTab(label, m, i);
					foreach (MessageTip t in m.get_tips_plural_form(i))
						auxtab.add_tip(t);
					this.add_tab(auxtab);
				}
			}
			this.message = m;
		}

		public MessageEditorTab? get_tab_by_plural_number (int plural_number)
		{
			if (plural_number > this.plurals_notebook.get_n_pages())
				return null;

			return this.plurals_notebook.get_nth_page (plural_number) as MessageEditorTab;
		}

		public void select_tab_by_plural_number (int plural_number)
		{
			if (plural_number > this.plurals_notebook.get_n_pages())
				return;
			this.plurals_notebook.set_current_page(plural_number);
		}

		private void add_tab (MessageEditorTab t)
		{
			this.plurals_notebook.append_page(t, t.label);
		}

		private void clean_tabs ()
		{
			int number_of_tabs = this.plurals_notebook.get_n_pages();
			for(int i=0;i<number_of_tabs;i++)
			{
				this.plurals_notebook.remove_page(0);
			}
		}

	}

	/**
	 * Editor pannel tabs.
	 */
	[GtkTemplate (ui = "/info/aquelando/valacat/messageeditortab.ui")]
	public class MessageEditorTab : Box
	{

		/*---------------------------- PROPERTIES ----------------------------*/

		/**
		 * Label of this editor tab.
		 */
		public Label label {get; private set;}


		/*------------------------- PRIVATE VARIABLES ------------------------*/

		[GtkChild]
		private SourceView textview_original_text;
		[GtkChild]
		private SourceView textview_translated_text;
		[GtkChild]
		private ListBox tips_box;

		private Message message;
		private int plural_number;

		private string _original_text;
		private string _tranlation_text;

		private string original_text {
			get {
				_original_text = this.plural_number == 0 ?
				this.message.get_original_singular () :
				this.message.get_original_plural ();
				return _original_text;
			}
		}

		private ArrayList<ValaCAT.TextTag> original_text_tags;

		private string? tranlation_text {
			get { _tranlation_text = this.tranlation_text = this.message.get_translation (this.plural_number);
				return _tranlation_text;}
			set { this.message.set_translation (this.plural_number, value);}
		}

		private ArrayList<ValaCAT.TextTag> translation_text_tags;

		/*--------------------------- CONSTRUCTORS ---------------------------*/

		/**
		 * Contructor for MessageEditorTabs. Initializes tab label
		 *	and strings.
		 */
		public MessageEditorTab (string label,
								 Message message,
								 int plural_number)
		{
			this.label = new Label(label);

			this.message = message;
			this.plural_number = plural_number;

			this.textview_original_text.buffer.set_text (this.original_text);

			if(this.tranlation_text != null)
				this.textview_translated_text.buffer.set_text (this.tranlation_text);


			this.original_text_tags = new ArrayList<ValaCAT.TextTag> ();
			this.translation_text_tags = new ArrayList<ValaCAT.TextTag> ();

			this.textview_translated_text.buffer.end_user_action.connect (update_translation);
		}


		/*------------------------------ METHODS -----------------------------*/

		/**
		 *
		 */
		public void add_tip (MessageTip t)
		{
			this.tips_box.add (new MessageTipRow(t));
		}

		/**
		 *
		 */
		public void remove_tip (MessageTip t)
		{
			foreach (Widget w in this.tips_box.get_children())
			{
				if ((w as MessageTipRow).tip == t)
				{
					this.tips_box.remove (w);
					return;
				}
			}
		}

		public void replace_tags_original_string (ArrayList<TextTag> tags)
		{
			this.clean_tags_original_string ();
			this.add_tags_original_string (tags);
		}

		public void add_tags_original_string (ArrayList<TextTag> tags)
		{
			foreach (TextTag tt in tags)
			{
				tt.add_to_buffer (this.textview_original_text.buffer, this.original_text.length);
				this.original_text_tags.add (tt);
			}
		}

		public void clean_tags_original_string ()
		{
			foreach (TextTag tt in this.original_text_tags)
				tt.remove_from_buffer (this.textview_original_text.buffer, this.original_text.length);
			this.original_text_tags.clear ();
		}

		public void replace_tags_translation_string (ArrayList<TextTag> tags)
		{
			this.clean_tags_translation_string ();
			this.add_tags_translation_string (tags);
		}

		public void add_tags_translation_string (ArrayList<TextTag> tags)
		{
			foreach (TextTag tt in tags)
			{
				tt.add_to_buffer (this.textview_translated_text.buffer, this.tranlation_text.length);
				this.translation_text_tags.add (tt);
			}
		}

		public void clean_tags_translation_string ()
		{
			foreach (TextTag tt in this.translation_text_tags)
				tt.remove_from_buffer (this.textview_translated_text.buffer, this.tranlation_text.length);
			this.translation_text_tags.clear ();
		}

		[GtkCallback]
		private void tip_enabled (ListBox source, ListBoxRow row)
		{
			this.replace_tags_original_string ((row as MessageTipRow).tip.tags_original);
			this.replace_tags_translation_string ((row as MessageTipRow).tip.tags_translation);
		}

		private void update_translation (TextBuffer buff)
		{
			string? old_text = this.tranlation_text;
			string? new_text = buff.text;

			if (old_text == null && new_text != null)
				this.message.state = MessageState.FUZZY;

			if (old_text != null && new_text == "")
				this.message.state = MessageState.UNTRANSLATED;

			this.tranlation_text = new_text == "" ? null : new_text;
			this.message.message_changed ();
		}
	}

	/**
	 * Rows of the tips displaying box.
	 */
	[GtkTemplate (ui = "/info/aquelando/valacat/messageeditortabtiprow.ui")]
	public class MessageTipRow : ListBoxRow
	{

		/**
		 *
		 */
		public MessageTip tip {get; private set;}

		[GtkChild]
		private Image icon;

		/**
		 *
		 */
		public MessageTipRow (MessageTip t)
		{
			switch (t.level)
			{
			case TipLevel.ERROR:
				icon.icon_name = "dialog-error-symbolic";
				break;
			case TipLevel.WARNING:
				icon.icon_name = "dialog-warning-symbolic";
				break;
			case TipLevel.INFO:
				icon.icon_name = "dialog-information-symbolic";
				break;
			}
			icon.tooltip_text = t.name + ": " + t.description;
			tip = t;
		}
	}

}
