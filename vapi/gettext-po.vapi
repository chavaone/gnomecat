
[CCode (cprefix = "Po", lower_case_cprefix = "po_")]
namespace GettextPo {


	[CCode(cheader_filename = "gettext-po.h", cname="struct po_file", free_function="po_file_free")]
	[Compact]
	public class File {

		[CCode (CCode = "po_file_create")]
		public File();

		[CCode (array_length = false, array_null_terminated = true, cname="po_file_domains")]
		public unowned string[] domains ();

		[CCode (cname="po_message_iterator")]
		public GettextPo.MessageIterator message_iterator (string domain);


		[CCode (cname="po_file_read")]
		public static GettextPo.File file_read (string filename,
							XErrorHandler handler);

		[CCode (cname="po_file_write")]
		public static GettextPo.File file_write (GettextPo.File file,
							string filename,
							XErrorHandler handler);

	}


	[CCode(cheader_filename = "gettext-po.h", cname="struct po_message_iterator", free_function="po_message_iterator_free")]
	[Compact]
	public class MessageIterator  {

		[CCode (has_construct_function = false)]
		public MessageIterator ();

		[CCode (cname="po_next_message")]
		public unowned GettextPo.Message next_message ();

		[CCode (cname="po_message_insert")]
		public void insert_message (GettextPo.Message m);
	}



	[CCode(cheader_filename = "gettext-po.h", cname="struct po_message")]
	[Compact]
	public class Message  {

		[CCode (cname="po_message_create")]
		public Message();
		public unowned string msgid ();
		public void set_msgid (string msgid);
		public unowned string? msgid_plural ();
		public void set_msgid_plural(string msgid_plural);
		public unowned string msgstr ();
		public void set_msgstr (string msgstr);
		public unowned string? msgstr_plural (int index);
		public void set_msgstr_plural (int index, string msgstr);
		public unowned string comments ();
		public void set_comments (string comments);
		public unowned string extracted_comments ();
		public void set_extracted_comments (string comments);
		public GettextPo.Filepos filepos (int i);
		public void remove_filepos (int i);
		public void add_filepos (string file, size_t start_line);
		public unowned bool is_obsolete();
		public void set_obsolete (bool obsolete);
		public unowned bool is_fuzzy ();
		public void set_fuzzy (bool fuzzy);
		public unowned bool is_format (string format_type);
		public void set_format(string format_type, int bool);
		public void check_format (GettextPo.ErrorHandler handler);
	}


	[CCode(cheader_filename = "gettext-po.h", free_function = "", cname="struct po_filepos")]
	[Compact]
	public class Filepos  {

		[CCode (has_construct_function = false)]
		public Filepos ();
		public string file ();
		public size_t start_line ();

	}

	[CCode(cheader_filename = "gettext-po.h", cname="struct po_error_handler")]
	public struct ErrorHandler
	{
	}

	[CCode(cheader_filename = "gettext-po.h", cname="struct po_xerror_handler")]
	public struct XErrorHandler
	{
	}

}
