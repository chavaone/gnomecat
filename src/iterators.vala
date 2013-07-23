using ValaCAT.FileProject;

namespace ValaCAT.Iterators
{

	/**
	 * Generic class for iterators. It iterates over
	 *	a element \\E\\ and returns instances of \\R\\.
	 */
	public abstract class Iterator<E,R> : Object
	{
		public abstract R? next ();
		public abstract R? previous ();
		public abstract void set_element (E element);
	}


	/**
	 *
	 */
	public abstract class MessageFilter : Object
	{
		public abstract bool check (Message m);
	}

	/**
	 *
	 */
	public class TranslatedFilter : MessageFilter
	{
		public override bool check (Message m)
		{
			return m.state == MessageState.TRANSLATED;
		}
	}

	/**
	 *
	 */
	public class UntranslatedFilter : MessageFilter
	{
		public override bool check (Message m)
		{
			return m.state == MessageState.UNTRANSLATED;
		}
	}

	/**
	 *
	 */
	public class FuzzyFilter : MessageFilter
	{
		public override bool check (Message m)
		{
			return m.state == MessageState.FUZZY;
		}
	}

	/**
	 *
	 */
	public class ORFilter : MessageFilter
	{

		public ArrayList<MessageFilter> filters {get; private set;}

		public ORFilter (ArrayList<MessageFilter> filters)
		{
			this.filters = filters;
		}

		public override bool check (Message m)
		{
			foreach (MessageFilter mf in filters)
				if (mf.check(m))
					return true;
			return false;
		}
	}


	/**
	 *
	 *
	 */
	public abstract class FileIterator : Iterator<File, Message>
	{
		public File file {get; private set;}
		public MessageFilter filter {get; private set;}


		private int current_index;
		private bool visited;
		private ArrayList<Message> messages;


		public FileIterator (File f)
		{
			this.with_filter(f,null);
		}


		public FileIterator.with_filter(File f, MessageFilter mf)
		{
			this.set_element(f);
			this.filter = mf;
		}


		public override void set_element (File f)
		{
			this.file = f;
			this.current_index = 0;
			this.visited = false;
			this.messages = f == null ? null : f.messages;
		}


		public override Message next ()
		{
			int index;

			if (! visited && check_condition(this.messages.get(current_index)))
			{
				this.visited = true;
				return this.messages.get(current_index);
			}

			for (index = index_circle_next (current_index);
				 check_condition(this.messages.get (index));
				 index = index_circle_next (index));

			current_index = index;
			this.visited = true;
			return this.messages.get(current_index);
		}


		public override Message previous ()
		{
			int index;

			if (! visited && check_condition(this.messages.get(current_index)))
			{
				this.visited = true;
				return this.messages.get(current_index);
			}

			for (index = index_circle_previous (current_index);
				 check_condition(this.messages.get (index));
				 index = index_circle_previous (index));

			current_index = index;
			this.visited = true;
			return this.messages.get(current_index);
		}


		private bool check_condition (Message m)
		{
			return this.filter != null ? this.filter.check(m) : true;
		}


		private int index_circle_next (int index)
		{
			int a = index + 1;
			return a >= this.messages.size ? 0 : a;
		}


		private int index_circle_previous (int index)
		{
			int a = index - 1;
			return a < 0 ? this.messages.size - 1 : a;
		}
	}


	/**
	 *
	 */
	public abstract class MessageIterator : Iterator<Message, MessageMark>
	{
		public Message message {get; private set;}

		public MessageIterator (Message msg)
		{
			this.set_element(msg);
		}

		public abstract MessageMark? next ();
		public abstract MessageMark? previous ();

		public override void set_element (Message element)
		{
			this.message = element;
		}
	}

	public class OriginalStringMessageIterator : MessageIterator
	{
		public string search_string {get; private set;}

		private ArrayList<MessageMark> marks;
		private int marks_index = -1;

		public OriginalStringMessageIterator ( Message msg, string search_string)
		{
			this.search_string = search_string;
			this.set_element(msg);
			this.marks = new ArrayList<MessageMark> ();
		}

		public override MessageMark? next ()
		{
			marks_index++;
			return marks_index < marks.size ? this.marks.get(marks_index) : null;
		}

		public override MessageMark? previous ()
		{
			marks_index--;
			return marks_index < 0 ? null : this.marks.get(marks_index);
		}

		private void get_marks ()
		{
			int index = 0;
			while ((index = this.message.get_original_singular().index_of(this.search_string, index)) != -1)
			{
				this.marks.add(new MessageMark(this.message, 0, true, index, this.search_string.char_count()));
			}

			if (this.message.has_plural())
			{
				while ((index = this.message.get_original_plural().index_of(this.search_string, index)) != -1)
				{
					this.marks.add(new MessageMark(this.message, 1, true, index, this.search_string.char_count()));
				}
			}
		}
	}


	public class TranslatedStringMessageIterator : MessageIterator
	{
		public string search_string {get; private set;}

		private ArrayList<MessageMark> marks;
		private int marks_index = -1;

		public TranslatedStringMessageIterator ( Message msg, string search_string)
		{
			this.search_string = search_string;
			this.set_element(msg);
			this.marks = new ArrayList<MessageMark> ();
			this.get_marks();
		}

		public override MessageMark? next ()
		{
			marks_index++;
			return marks_index < marks.size ? this.marks.get(marks_index) : null;
		}

		public override MessageMark? previous ()
		{
			marks_index--;
			return marks_index < 0 ? null : this.marks.get(marks_index);
		}

		private void get_marks ()
		{
			int index = 0;
			while ((index = this.message.get_translation(0).index_of(this.search_string, index)) != -1)
			{
				this.marks.add(new MessageMark(this.message, 0, false, index, this.search_string.char_count()));
			}

			if (this.message.has_plural())
			{
				for(int plural_number = 1; plural_number < message.file.number_of_plurals (); i++)
				{
					string message_string = this.message.get_translation(plural_number);
					if (message_string != null)
					{
						while ((index = message_string.index_of(this.search_string, index)) != -1)
						{
							this.marks.add(new MessageMark(this.message, plural_number, false, index, this.search_string.char_count()));
						}
					}
				}
			}
		}
	}

	/**
	 * Object that marks a certain string in a message.
	 */
	public class MessageMark : Object
	{
		/**
		 * Message that references.
		 */
		public Message message {get; private set;}

		/**
		 *
		 */
		public int plural_number {get; private set;}

		/**
		 *
		 */
		public bool is_original {get; private set;}

		/**
		 *
		 */
		public int index {get; private set;}

		/**
		 *
		 */
		public int length {get; private set;}


		public MessageMark (Message m, int plural_number, bool is_original, int index, int length)
		{
			this.message = m;
			this.plural_number = plural_number;
			this.is_original = is_original;
			this.index = index;
			this.length = length;
		}
	}

}