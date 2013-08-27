

using ValaCAT.FileProject;
using Gee;
using ValaCAT.Iterators;
using ValaCAT.UI;

namespace ValaCAT.Navigator
{

	public class Navigator : Object, ChangedMessageSensible
	{
		public ValaCAT.FileProject.File file {get {return filetab.file;}}
		private FileIterator iterator;
		private IteratorFilter<Message> filter;
		private ValaCAT.UI.FileTab filetab;


		public Navigator (FileTab ft, IteratorFilter<Message> filter)
		{
			filetab = ft;
			iterator = new FileIterator (ft.file, filter);
			this.filter = filter;
		}

		public void next_item ()
		{
			Message? m = iterator.next ();

			if (m == null)
			{
				iterator.first ();
				m = iterator.get_current_element ();
			}

			if (m == null)
				return; //FIXME

			MessageListRow? row = filetab.message_list.find_row_by_message (m);
			filetab.message_list.select_row (row);
		}

		public void previous_item ()
		{
			Message? m = iterator.previous ();

			if (m == null)
			{
				iterator.last ();
				m = iterator.get_current_element ();
			}

			if (m == null)
				return; //FIXME

			MessageListRow? row = filetab.message_list.find_row_by_message (m);
			filetab.message_list.select_row (row);
		}

		public void set_message (Message m)
		{
			if (filter.check (m))
			{
				set_message_intern (m);
			}
			else
			{
				Gee.ArrayList<Message> msgs = this.file.messages;
				int index;
				for (index = msgs.index_of (m); index >= 0 && ! filter.check (msgs.get (index)); index--);

				if (index == -1)
					iterator.first ();
				else
					set_message_intern (msgs.get (index));
			}
		}

		private void set_message_intern (Message m)
		{
			Message? current_message = null;
			iterator.first ();
			do
			{
				current_message = this.iterator.next ();
			}
			while (current_message != m && current_message != null);

			if (current_message == null)
			{
				print ("ERROR!!"); //TODO
			}
		}

	}
}