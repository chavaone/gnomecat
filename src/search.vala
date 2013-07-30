
using Gtk;
using Gee;
using ValaCAT.FileProject;
using ValaCAT.Iterators;
using ValaCAT.Search;
using ValaCAT.UI;

namespace ValaCAT.UI
{

	/**
	 *
	 */
	[GtkTemplate (ui = "/info/aquelando/valacat/searchdialog.ui")]
	public class SearchDialog : Gtk.Dialog
	{
		[GtkChild]
		private Gtk.Entry entry_search;
		[GtkChild]
		private Gtk.Entry entry_replace;
		[GtkChild]
		private Gtk.CheckButton checkbutton_translated_messages;
		[GtkChild]
		private Gtk.CheckButton checkbutton_fuzzy_messages;
		[GtkChild]
		private Gtk.CheckButton checkbutton_untranslated_messages;
		[GtkChild]
		private Gtk.CheckButton checkbutton_translated;
		[GtkChild]
		private Gtk.CheckButton checkbutton_original;
		[GtkChild]
		private Gtk.CheckButton checkbutton_search_project;
		[GtkChild]
		private Gtk.CheckButton checkbutton_wrap_around;

		private ValaCAT.UI.Window window;


		public SearchDialog (Window w)
		{
			this.window = w;
		}

		[GtkCallback]
		private void search_clicked (Button b)
		{
			ini_search(false,true);
		}

		[GtkCallback]
		private void replace_clicked (Button b)
		{
			ini_search(true,true);
		}

		[GtkCallback]
		private void replace_all_clicked (Button b)
		{
			ini_search(true,false);
		}

		[GtkCallback]
		private void close_search_dialog (Widget w)
		{
			this.visible = false;
		}

		private void ini_search (bool replace, bool stop)
		{

			if (! checkbutton_search_project.active && this.window.get_active_tab () is FileTab)
			{
				this.window.active_search = new FileSearch (this.window.get_active_tab() as FileTab,
															checkbutton_translated_messages.active,
															checkbutton_untranslated_messages.active,
															checkbutton_fuzzy_messages.active,
															checkbutton_original.active,
															checkbutton_translated.active,
															replace,
															stop,
															entry_search.get_text (),
															entry_replace.get_text ());
			}
			else
			{
				//this.window.active_search = new ProjectSearch();
			}

			this.window.active_search.next_item();
			this.hide();
		}

	}
}


namespace ValaCAT.Search
{
	public abstract class Search : Object
	{
		public abstract string get_search_text ();

		public abstract string get_replace_text ();

		public abstract void next_item ();

		public abstract void previous_item ();

		public abstract void replace ();
	}


	/*
	public class ProjectSearch : Search
	{
	}
	*/


	public class FileSearch : Search
	{

		private ValaCAT.UI.FileTab filetab;
		private FileIterator file_iterator;
		private MessageIterator message_iterator;
		private bool has_to_replace;
		private bool stop;
		private string replace_text;
		private string search_text;


		public FileSearch (ValaCAT.UI.FileTab tab,
						 bool translated,
						 bool untranslated,
						 bool fuzzy,
						 bool original,
						 bool translation,
						 bool replace,
						 bool stop,
						 string search_text,
						 string replace_text)
		{

			//FILTERS MESSAGES
			ArrayList<IteratorFilter<Message>> filters_file = new ArrayList<IteratorFilter<Message>> ();
			if (translated)
				filters_file.add(new TranslatedFilter ());

			if (untranslated)
				filters_file.add(new UntranslatedFilter ());

			if (fuzzy)
				filters_file.add(new FuzzyFilter ());


			IteratorFilter<Message> filter_messages;

			if(filters_file.size == 0)
				filter_messages = null;
			else if (filters_file.size == 1)
				filter_messages = filters_file.get(0);
			else
				filter_messages = new ORFilter<Message> (filters_file);


			//FILTERS MESSAGE MARKS
			ArrayList<IteratorFilter<MessageMark>> filters_mark_array = new ArrayList<IteratorFilter<MessageMark>> ();
			if (original)
				filters_mark_array.add (new OriginalFilter());

			if (translation)
				filters_mark_array.add (new TranslationFilter());


			IteratorFilter<MessageMark> filter_marks;

			if(filters_mark_array.size == 0)
				filter_marks = null;
			else if (filters_mark_array.size == 1)
				filter_marks = filters_mark_array.get(0);
			else
				filter_marks = new ORFilter<MessageMark> (filters_mark_array);


			this.filetab = tab;
			this.file_iterator = new FileIterator(tab.file,filter_messages);
			this.file_iterator.first();
			this.message_iterator = new MessageIterator(null, search_text, filter_marks);
			this.has_to_replace = replace;
			this.stop = stop;
			this.replace_text = replace_text;
			this.search_text = search_text;
		}


		public override void next_item ()
		{
			MessageMark mm = null;

			while (mm == null)
			{
				if (this.message_iterator.message == null || (mm = this.message_iterator.next()) == null)
				{
					Message message;;
					if((message = this.file_iterator.next()) == null)
						return;
					this.message_iterator.set_element(message);
					//stdout.printf("Message %s\n",message.get_original_singular()); //DEBUG
				}
			}

			this.highlight_search(mm);
		}

		public override void previous_item ()
		{
			MessageMark mm = null;

			while (mm == null)
			{
				if (this.message_iterator.message == null || (mm = this.message_iterator.previous()) == null)
				{
					this.message_iterator.set_element(this.file_iterator.previous());
					this.message_iterator.last();
				}
			}

			this.highlight_search(mm);
		}

		public override string get_search_text ()
		{
			return this.search_text;
		}

		public override string get_replace_text ()
		{
			return this.replace_text;
		}

		public override void replace ()
		{
			MessageMark mm = this.message_iterator.get_current_element();
			replace_intern(mm);
		}

		private void highlight_search_debug (MessageMark mm) //DEBUG
		{
			stdout.printf("Message %s... :: Index %i :: Length %i :: String %s\n",
				mm.message.get_original_singular().substring(0,5),
				mm.index,
				mm.length,
				mm.message.get_original_singular().substring (mm.index, mm.length));
		}

		private void highlight_search (MessageMark mm)
		{
			ValaCAT.UI.MessageListRow? row = this.filetab.message_list.find_row_by_message (mm.message);

			if (row != null)
			{
				this.filetab.message_list.select_row (row);
			}
			else
			{
				return;
			}

			MessageEditorTab editor_tab = this.filetab.message_editor.get_tab_by_plural_number (mm.plural_number);

			if (mm.is_original)
			{
				ArrayList<ValaCAT.TextTag> arr = new ArrayList<ValaCAT.TextTag> ();
				arr.add (mm.get_tag ());
				editor_tab.replace_tags_original_string (arr);
			}
			else
			{
				ArrayList<ValaCAT.TextTag> arr = new ArrayList<ValaCAT.TextTag> ();
				arr.add (mm.get_tag ());
				editor_tab.replace_tags_translation_string (arr);
			}
		}

		private void replace_intern (MessageMark mm)
		{
			if (mm.is_original)
			{
				return;
			}
			else
			{
				string original_string = mm.message.get_translation(mm.plural_number);
				mm.message.set_translation(mm.plural_number,
					original_string.substring (0,mm.index) + this.replace_text +
					original_string.substring (mm.index + mm.length));
			}
		}
	}
}