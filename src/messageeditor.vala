using Gdl;
using Gtk;
using ValaCAT.FileProject;

namespace ValaCAT.MessageEditor
{

	/**
	 * Editing pannel widget.
	 */
	[GtkTemplate (ui = "/info/aquelando/valacat/messageeditor.ui")]
	public class MessageEditorWidget : DockItem
	{
		[GtkChild]
		private Notebook plurals_notebook;

		public MessageEditorWidget ()
		{}

		public set_message (Message m)
		{
			this.clean_tabs();
			//TODO: Add gettext integration.
			var auxtab = new MessageEditorTab("Singular", m.get_original_singular(), m.get_translation(0));
			foreach (MessageTip t in m.get_tips_plural_form(i-1))
				auxtab.add_tip(t);
			this.add_tab(auxtab);

			if ( m.has_plural() )
			{
				for(int i = m.get_language().get_number_of_plurals(); i > 1; i--)
				{
					string label = "Plural:"; //TODO: add language plural tags and gettext.
					var auxtab = new MessageEditorTab(label,m.get_original_plural(), m.get_translation(i-1));
					foreach (MessageTip t in m.get_tips_plural_form(i-1))
						auxtab.add_tip(t);
					this.add_tab(auxtab);
				}
			}
		}

		private void add_tab (MessageEditorTab t)
		{
			this.plurals_notebook.append_page(t, t.get_label());
		}
	}

	/**
	 * Editor pannel tabs.
	 */
	[GtkTemplate (ui = "/info/aquelando/valacat/messageeditor.ui")]
	public class MessageEditorTab : Box
	{

		/*---------------------------- PROPERTIES ----------------------------*/

		/**
		 * Label of this editor tab.
		 */
		public Label label {get; private set;}


		/*------------------------- PRIVATE VARIABLES ------------------------*/

		[GtkChild]
		private TextView textview_original_text;
		[GtkChild]
		private TextView textview_translated_text;
		[GtkChild]
		private ListBox tips_box;
		private MessageString original_text;
		private MessageString tranlation_text;


		/*--------------------------- CONSTRUCTORS ---------------------------*/

		/**
		 * Contructor for MessageEditorTabs. Initializes tab label
		 *	and strings.
		 */
		public MessageEditorTab (string label,
								 string original,
								 string translation)
		{
			this.label = new Label(label);
			this.original_text = new BaseString (original);
			this.tranlation_text = new BaseString (translation);
			this.update_textviews();
		}


		/*------------------------------ METHODS -----------------------------*/

		/**
		 *
		 */
		public void add_tip (MessageTip t)
		{
		}

		/**
		 *
		 */
		public void remove_tip (MessageTip t)
		{
		}

		/**
		 *
		 */
		public void add_filter_translation_string (Filter f)
		{
			f.base_message_string = this.tranlation_text;
			this.tranlation_text = f;
			this.update_textviews();
		}

		/**
		 *
		 */
		public void add_filter_original_string (Filter f)
		{
			f.base_message_string = this.original_text;
			this.original_text = f;
			this.update_textviews();
		}

		/**
		 *
		 */
		public void disable_filters_original_string ()
		{
			this.original_text.recursive_disable();
			this.update_textviews();
		}

		/**
		 *
		 */
		public void disable_filters_translation_string ()
		{
			this.tranlation_text.recursive_disable();
			this.update_textviews();
		}

		private void update_textviews ()
		{
			this.textview_original_text.set_text(this.original_text.get_string());
			this.textview_translated_text.set_text(this.tranlation_text.get_string());
		}
	}

	/**
	 * Rows of the tips displaying box.
	 */
	[GtkTemplate (ui = "/info/aquelando/valacat/messageeditor.ui")]
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
			case ERROR:
				icon.icon_name = "dialog-error-symbolic";
			case WARNING:
				icon.icon_name = "dialog-warning-symbolic";
			case INFO:
				icon.icon_name = "dialog-information-symbolic";
			}
			icon.tooltip_text = t.description;
			this.tip = t;
		}
	}

}