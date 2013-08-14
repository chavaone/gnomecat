/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

using Gtk;
using ValaCAT.FileProject;

namespace ValaCAT
{
	public interface ChangedMessageSensible : Object
	{
		public abstract void set_message (Message m);
	}

	public class TextTag : Object
	{

		public Gtk.TextTag tag {get; private set;}
		public int ini_offset {get; private set;}
		public int end_offset {get; private set;}

		public TextTag (Gtk.TextTag tag)
		{
			this.with_range(tag,-1,-1);
		}

		public TextTag.with_range (Gtk.TextTag tag, int ini_offset, int end_offset)
		{
			this.tag = tag;
			this.ini_offset = ini_offset;
			this.end_offset = end_offset;
		}

		public void add_to_buffer (TextBuffer buffer, int text_size)
		{
			TextIter ini_iter = TextIter ();
			if (this.ini_offset == -1)
				buffer.get_iter_at_offset (out ini_iter, 0);
			else
				buffer.get_iter_at_offset (out ini_iter, this.ini_offset);

			TextIter end_iter = TextIter ();
			if (this.end_offset == -1)
				buffer.get_iter_at_offset(out end_iter, text_size - 1);
			else
				buffer.get_iter_at_offset(out end_iter, this.end_offset);

			buffer.tag_table.add(this.tag);
			buffer.apply_tag_by_name(this.tag.name, ini_iter, end_iter);
		}

		public void remove_from_buffer (TextBuffer buffer, int text_size)
		{
			TextIter ini_iter = TextIter ();
			if (this.ini_offset == -1)
				buffer.get_iter_at_offset (out ini_iter, 0);
			else
				buffer.get_iter_at_offset (out ini_iter, this.ini_offset);

			TextIter end_iter = TextIter ();
			if (this.end_offset == -1)
				buffer.get_iter_at_offset(out end_iter, text_size - 1);
			else
				buffer.get_iter_at_offset(out end_iter, this.end_offset);

			buffer.remove_tag_by_name(this.tag.name, ini_iter, end_iter);
			buffer.tag_table.remove(this.tag);
		}
	}
}
