
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

        [CCode (cname="po_file_domain_header")]
        public string domain_header (string domain);

        [CCode (cname="po_file_check_all")]
        public void check (XErrorHandler handler);

        [CCode (cname="po_file_read")]
        public static GettextPo.File file_read (string filename,
                            XErrorHandler handler);

        [CCode (cname="po_file_write")]
        public static unowned GettextPo.File file_write (GettextPo.File file,
                            string filename,
                            XErrorHandler handler);

        [CCode (cname="po_header_field")]
        public static string header_field (string header, string field);


        [CCode (cname="po_header_set_field")]
        public static string header_set_field (string header, string field, string value);
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
        public unowned bool is_obsolete ();
        public void set_obsolete (bool obsolete);
        public unowned bool is_fuzzy ();
        public void set_fuzzy (bool fuzzy);
        public unowned bool is_format (string format_type);
        public void set_format (string format_type, bool value);
        public void check_format (GettextPo.XErrorHandler handler);
        public void check_all (GettextPo.MessageIterator iterator, XErrorHandler handler);
    }


    [CCode(cheader_filename = "gettext-po.h", free_function = "", cname="struct po_filepos")]
    [Compact]
    public class Filepos  {

        [CCode (has_construct_function = false)]
        public Filepos ();
        public unowned string file ();
        public size_t start_line ();

    }


    /* Format Types */

    /* Return a NULL terminated array of the supported format types.  */
    [CCode(cheader_filename = "gettext-po.h", cname="po_format_list", array_length = false, array_null_terminated = true)]
    public unowned string[] format_list ();

    /* Return the pretty name associated with a format type.
     For example, for "csharp-format", return "C#".
     Return NULL if the argument is not a supported format type.*/
    [CCode(cheader_filename = "gettext-po.h", cname="po_format_pretty_name")]
    public unowned string format_pretty_name (string format_name);


    /* Errors */

    /* Signal an error.  The error message is built from FORMAT and the following
     arguments.  ERRNUM, if nonzero, is an errno value.
     Must increment the error_message_count variable declared in error.h.
     Must not return if STATUS is nonzero.  */
    [CCode (has_target = false)]
    public delegate void ErrorFunc (int status, int errnum, string format);

    /* Signal an error.  The error message is built from FORMAT and the following
     arguments.  The error location is at FILENAME line LINENO. ERRNUM, if
     nonzero, is an errno value.
     Must increment the error_message_count variable declared in error.h.
     Must not return if STATUS is nonzero.  */
    [CCode (has_target = false)]
    public delegate void ErrorAtLineFunc (int status, int errnum, string filename, int lineno);

    /* Signal a multiline warning.  The PREFIX applies to all lines of the
     MESSAGE.  Free the PREFIX and MESSAGE when done.  */
    [CCode (has_target = false)]
    public delegate void MultilineWarnFunc (string prefix, string message);

    /* Signal a multiline error.  The PREFIX applies to all lines of the
     MESSAGE.  Free the PREFIX and MESSAGE when done.
     Must increment the error_message_count variable declared in error.h if
     PREFIX is non-NULL.  */
    [CCode (has_target = false)]
    public delegate void MultilineErrorFunc (string prefix, string message);

    [CCode(cheader_filename = "gettext-po.h", cname="struct po_error_handler", has_destroy_function = false)]
    public struct ErrorHandler
    {
        ErrorFunc error;
        ErrorAtLineFunc error_at_line;
        MultilineWarnFunc multiline_warning;
        MultilineErrorFunc multiline_error;
    }

    [CCode (cname = "int", cprefix = "SEVERITY_", has_type_id = false)]
    public enum Severity {
        WARNING = 0,
        ERROR = 1,
        FATAL_ERROR = 2
    }

    /* Signal a problem of the given severity.
     MESSAGE and/or FILENAME + LINENO indicate where the problem occurred.
     If FILENAME is NULL, FILENAME and LINENO and COLUMN should be ignored.
     If LINENO is (size_t)(-1), LINENO and COLUMN should be ignored.
     If COLUMN is (size_t)(-1), it should be ignored.
     MESSAGE_TEXT is the problem description (if MULTILINE_P is true,
     multiple lines of text, each terminated with a newline, otherwise
     usually a single line).
     Must not return if SEVERITY is PO_SEVERITY_FATAL_ERROR.  */
    [CCode (has_target = false)]
    public delegate void XErrorFunc (GettextPo.Severity severity,
            GettextPo.Message message,
            string? filename,
            size_t lineno,
            size_t column,
            int multiline_p,
            string message_text);

    /* Signal a problem that refers to two messages.
     Similar to two calls to xerror.
     If possible, a "..." can be appended to MESSAGE_TEXT1 and prepended to
     MESSAGE_TEXT2.  */
    [CCode (has_target = false)]
    public delegate void XError2Func (GettextPo.Severity severity,
                   GettextPo.Message message1,
                   string? filename1,
                   size_t lineno1,
                   size_t column1,
                   int multiline_p1,
                   string message_text1,
                   GettextPo.Message message2,
                   string? filename2,
                   size_t lineno2,
                   size_t column2,
                   int multiline_p2,
                   string message_text2);


    [CCode(cheader_filename = "gettext-po.h", cname="struct po_xerror_handler", has_destroy_function = false)]
    public struct XErrorHandler
    {
        XErrorFunc xerror;
        XError2Func xerror2;
    }

}
