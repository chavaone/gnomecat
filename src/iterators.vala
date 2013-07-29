
using Gee;
using ValaCAT.FileProject;

namespace ValaCAT.Iterators
{

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

	/**
	 *
	 */
	public abstract class IteratorFilter<E> : Object
	{
		/**
		 *
		 */
		public abstract bool check (E element);
	}


	/**
	 *
	 */
	public class TranslatedFilter : IteratorFilter<Message>
	{
		public override bool check (Message element)
		{
			return element.state == MessageState.TRANSLATED;
		}
	}

	/**
	 *
	 */
	public class UntranslatedFilter : IteratorFilter<Message>
	{
		public override bool check (Message element)
		{
			return element.state == MessageState.UNTRANSLATED;
		}
	}

	/**
	 *
	 */
	public class FuzzyFilter : IteratorFilter<Message>
	{
		public override bool check (Message element)
		{
			return element.state == MessageState.FUZZY;
		}
	}

	/**
	 *
	 */
	public class ORFilter<R> : IteratorFilter<R>
	{

		public ArrayList<IteratorFilter<R>> filters {get; private set;}

		public ORFilter (ArrayList<IteratorFilter<R>> filters)
		{
			this.filters = filters;
		}

		public override bool check (R m)
		{
			foreach (IteratorFilter<R> mf in filters)
				if (mf.check(m))
					return true;
			return false;
		}
	}

	/**
	 *
	 */
	public class OriginalFilter : IteratorFilter<MessageMark>
	{
		public override bool check (MessageMark mm)
		{
			return mm.is_original;
		}
	}

	/**
	 *
	 */
	public class TranslationFilter : IteratorFilter<MessageMark>
	{
		public override bool check (MessageMark mm)
		{
			return ! mm.is_original;
		}
	}

	/**
	 *
	 */
	public class AllMessageMarkFilter : IteratorFilter<MessageMark>
		{
		public override bool check (MessageMark mm)
		{
			return true;
		}
	}


	/**
	 * Generic class for iterators. It iterates over
	 *	a element \\E\\ and returns instances of \\R\\.
	 */
	public abstract class Iterator<Ele,Ret> : Object
	{
		public abstract Ret  next ();
		public abstract Ret  previous ();
		public abstract Ret  get_current_element ();
		public abstract void last ();
		public abstract void first ();
		public abstract bool is_last();
		public abstract void set_element (Ele element);
	}


	/**
	 *
	 *
	 */
	public class FileIterator : Iterator<ValaCAT.FileProject.File?, Message?>
	{
		public ValaCAT.FileProject.File file {get; private set;}
		public IteratorFilter<Message> filter {get; private set;}


		private int current_index;
		private bool visited;
		private ArrayList<Message> messages;


		public FileIterator (ValaCAT.FileProject.File? f, IteratorFilter<Message> mf)
		{
			this.set_element(f);
			this.filter = mf;
		}


		public override void set_element (ValaCAT.FileProject.File? f)
		{
			this.file = f;
			this.messages = f == null ? null : f.messages;
			this.first();
		}


		public override Message? next ()
		{
			if (visited || ! check_condition(messages.get(current_index)))
			{
				for (current_index++;
					 current_index < messages.size && ! check_condition (messages.get (current_index));
					 current_index++);
			}

			this.visited = true;
			return this.get_current_element ();
		}


		public override Message? previous ()
		{

			if (visited || ! check_condition(messages.get(current_index)))
			{
				for (current_index--;
					 current_index >= 0 && ! check_condition (this.messages.get (current_index));
					 current_index--);
			}

			this.visited = true;
			return this.get_current_element ();
		}


		public override void first ()
		{
			this.current_index = 0;
			this.visited = false;
		}

		public override void last ()
		{
			this.current_index = this.messages.size - 1;
			this.visited = false;
		}

		public override bool is_last ()
		{
			return this.current_index == this.messages.size -1;
		}

		public override Message? get_current_element ()
		{
			if (this.messages == null || this.current_index < 0 ||
				this.current_index >= this.messages.size)
				return null;
			if (! visited)
				return next();
			return this.messages.get(this.current_index);
		}

		private bool check_condition (Message m)
		{
			return 	this.filter != null && this.filter.check(m);
		}
	}


	/**
	 *
	 */
	public class MessageIterator : Iterator<Message?, MessageMark?>
	{
		public Message message {get; private set;}
		public string search_string {get; private set;}

		private ArrayList<MessageMark> marks;
		private int marks_index;
		private IteratorFilter<MessageMark> filter;

		public MessageIterator (Message? msg, string search_string, IteratorFilter<MessageMark> filter)
		{
			this.search_string = search_string;
			this.marks = new ArrayList<MessageMark> ();
			if (msg != null)
				this.set_element(msg);
			this.filter = filter;
		}

		public override MessageMark? next ()
		{
			marks_index++;
			return this.get_current_element ();
		}

		public override MessageMark? previous ()
		{
			marks_index--;
			return this.get_current_element ();
		}

		public override void first ()
		{
			marks_index = 0;
		}

		public override void last ()
		{
			marks_index = this.marks.size - 1;
		}

		public override bool is_last ()
		{
			return marks_index == marks.size - 1;
		}

		public override MessageMark? get_current_element ()
		{
			if(this.marks == null || marks_index < 0 || marks_index >= this.marks.size)
				return null;
			return this.marks.get(marks_index);
		}

		public override void set_element (Message? element)
		{
			this.message = element;
			this.marks.clear();
			if(element != null)
				this.get_marks();
			this.marks_index = -1;
		}

		private void get_marks ()
		{
			stdout.printf("GETMARKS Message \"%s...\" SEARCH \"%s\"\n",
				message.get_original_singular().substring(0,5),
				this.search_string); //DEBUG
			int index;
			MessageMark mm;

			for	(index = message.get_original_singular().index_of(this.search_string);
				index != -1;
				index = this.message.get_original_singular().index_of(this.search_string, ++index))
			{
				mm = new MessageMark(this.message, 0, true, index, this.search_string.char_count());
				if(this.check_mark(mm))
					this.marks.add(mm);
			}

			index = 0;
			while ((index = this.message.get_translation(0).index_of(this.search_string, index)) != -1)
			{
				mm = new MessageMark(this.message, 0, false, index, this.search_string.char_count());
				if(this.check_mark(mm))
					this.marks.add(mm);
				index++;
			}

			if (this.message.has_plural())
			{
				index = 0;
				while ((index = this.message.get_original_plural().index_of(this.search_string, index)) != -1)
				{
					mm = new MessageMark(this.message, 1, true, index, this.search_string.char_count());
					if(this.check_mark(mm))
						this.marks.add(mm);
					index++;
				}

				for(int plural_number = 1; plural_number < message.file.number_of_plurals (); plural_number++)
				{
					index = 0;
					string message_string = this.message.get_translation(plural_number);
					if (message_string != null)
					{
						while ((index = message_string.index_of(this.search_string, index)) != -1)
						{
							mm = new MessageMark(this.message, plural_number, false, index, this.search_string.char_count());
							if(this.check_mark(mm))
								this.marks.add(mm);
							index++;
						}
					}
				}
			}

			foreach (MessageMark m in marks)
				stdout.printf("Message %s... Index %i\n",
					m.message.get_original_singular().substring(0,5),
					m.index);

		}

		private bool check_mark (MessageMark mm)
		{
			return this.filter == null ? false : this.filter.check(mm);
		}
	}

}