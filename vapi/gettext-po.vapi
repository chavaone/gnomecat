
[CCode (cprefix = "Po", lower_case_cprefix = "po_")]
namespace GettextPo {


	[CCode(cheader_filename = "gettext-po.h", type="po_file_t", free_function="po_file_free")]
	[Compact]
	public class File : Glib.Object {

		[CCode (CCode = "po_file_create")]
		public File();

		public string[] domains ();

		[CCode (cname="po_message_iterator")]
		public GettextPo.MessageIterator message_iterator (string domain);


		[CCode (cname="po_file_read")]
		static public GettextPo.File file_read (string filename,
							ErrorHandler handler);

		[CCode (cname="po_file_write")]
		static public GettextPo.File file_write (GettextPo.File file,
							string filename,
							ErrorHandler handler);

	}


	[CCode(cheader_filename = "gettext-po.h", type="po_message_iterator_t", free_function="po_message_iterator_free")]
	[Compact]
	public class MessageIterator : Glib.Object {

		[CCode (has_construct_function = false)]
		public MessageIterator ();

		[CCode (cname="po_next_message")]
		public GettextPo.Message next_message ();

		[CCode (cname="po_message_insert")]
		public void insert_message (GettextPo.Message m);
	}



	[CCode(cheader_filename = "gettext-po.h", type="po_message_t")]
	[Compact]
	public class Message : Glib.Object {

		[CCode (cname="po_message_create")]
		public Message();
		public string msgid ();
		public void set_msgid (string msgid);
		public string msgid_plural ();
		public void set_msgid_plural(string msgid_plural);
		public string msgstr ();
		public void set_msgstr (string msgstr);
		public string msgstr_plural (int index);
		public void set_msgstr_plural (int index, string msgstr);
		public string comments ();
		public void set_comments (string comments);
		public string extracted_comments ();
		public void set_extracted_comments (string comments);
		public GettextPo.FilePos filepos (int i);
		public void remove_filepos (int i);
		public void add_filepos (string file, size_t start_line);
		public bool is_obsolete();
		public void set_obsolete (bool obsolete);
		public bool is_fuzzy ();
		public void set_fuzzy (bool fuzzy);
		public bool is_format (string format_type);
		public void set_format(string format_type, int bool);
		public void check_format (GettextPo.ErrorHandler handler);
	}


	[CCode(cheader_filename = "gettext-po.h", type="po_filepos_t")]
	[Compact]
	public class FilePos : GLib.Object {

		[CCode (has_construct_function = false)]
		public FilePos ();
		public string file ();
		public size_t start_line ();

	}

	[CCode(cheader_filename = "gettext-po.h", type="po_error_handler_t")]
	[Compact]
	public class ErrorHandler : GLib.Object {}

}
