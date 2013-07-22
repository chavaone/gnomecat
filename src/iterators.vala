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
	 *
	 */
	public abstract class FileIterator : Iterator<File, Message>
	{
		public File file {get; private set;}

		private int current_index;
		private bool visited;
		private ArrayList<Message> messages;

		public FileIterator ()
		{
			this.with_file(null);
		}

		public FileIterator.with_file(File f)
		{
			this.set_element(f);
		}

		public virtual void set_element (File f)
		{
			this.file = f;
			this.current_index = 0;
			this.visited = false;
			this.messages = f == null ? null : f.messages;
		}

		public virtual Message next ()
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

		public virtual Message previous ()
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


		protected abstract bool check_condition (Message m);

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
	public class TranslatedFileIterator : FileIterator
	{
		protected override bool check_condition (Message m)
		{
			return m.state == MessageState.TRANSLATED;
		}
	}


	/**
	 *
	 */
	public class UntranslatedFileIterator : FileIterator
	{
		protected override bool check_condition (Message m)
		{
			return m.state == MessageState.UNTRANSLATED;
		}
	}


	/**
	 *
	 */
	public class FuzzyFileIterator : FileIterator
	{
		protected override bool check_condition (Message m)
		{
			return m.state == MessageState.FUZZY;
		}
	}


	/**
	 *
	 */
	public class ORFileIterator : FileIterator
	{

		public ArrayList<FileIterator> iterators {get; private set;}

		public ORFileIterator (ArrayList<FileIterator> iterators)
		{
			this.iterators = iterators;
		}


		public override void set_element (File f)
		{
			//DO NOTHING
		}

		protected override bool check_condition (Message m)
		{
			foreach (FileIterator fi in iterators)
				if(fi.check_condition(m))
					return true;
			return false;
		}
	}

	/**
	 *
	 */
	public abstract class MessageIterator : Iterator<Message, MessageMark>
	{
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