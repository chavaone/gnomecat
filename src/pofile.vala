

using GettextPo;
using ValaCAT.FileProject;
using ValaCAT.Languages;

namespace ValaCAT.PoFiles
{
    public class PoMessage : ValaCAT.FileProject.Message
    {
        private unowned GettextPo.Message message;

        public PoMessage (PoFile owner_file, GettextPo.Message msg)
        {
            base (owner_file);
            this.message = msg;
        }


        /**
         * Method that indicates if this string has or has not
         *  a plural form.
         */
        public override bool has_plural ()
        {
            return this.message.msgid_plural () != null;
        }

        /**
         * Returns the originals singular text of this message.
         */
        public override string get_original_singular ()
        {
            return this.message.msgid ();
        }

        /**
         * Returns the original plural text of this message or
         *  \\null\\ if there is no plural.
         */
        public override string get_original_plural ()
        {
            return this.message.msgid_plural ();
        }

        /*
         * Gets the translated string that has the number
         *  provided by parameter.
         *
         * @param index Number of the requested translation.
         * @return The translated string.
         */
        public override string get_translation (int index)
        {
            return  index == 0 ?
                    this.message.msgstr () :
                    this.message.msgstr_plural (index - 1);
        }

        /*
         * Modifies the translated string that has the number
         *  provided by paramenter.
         *
         * @param index
         * @param translation
         * @return The previous string or \\null\\ if there
         *  isn't previous string
         */
        public override void set_translation (int index,
                                            string? translation)
        {
            if (index == 0)
                this.message.set_msgstr (translation == null ? "" : translation);
            else
                this.message.set_msgstr_plural (index, translation == null ? "" : translation);
        }

        /**
         * Method that returns a string containing additional
         * information of this message such as context, translator
         * comments, etc.
         */
         public override string get_context ()
         {
            return "Coments\n" + this.message.comments () +
                "\nExtracted Comments\n" + this.message.extracted_comments ();
         }
    }

    public class PoFile : ValaCAT.FileProject.File
    {
        private GettextPo.File file;

        public PoFile.full (string path, Project? p)
        {
            base.full (path, p);
        }

        /**
         * Method that saves the instance of this File into
         *  a file indicated as parameter.
         */
        public override void save_file (string? file_path=null)
        {
            XErrorHandler err_hand = XErrorHandler();
            GettextPo.File.file_write (this.file,
                file_path == null ? this.file_path : file_path, err_hand);
        }

        /**
         * Method that parses a file in order to populate
         *  this instance of File.
         */
        public override void parse_file (string path)
        {
            XErrorHandler err_hand = XErrorHandler();
            this.file = GettextPo.File.file_read (path, err_hand);
            foreach (string d in this.file.domains())
            {
                MessageIterator mi = this.file.message_iterator (d);
                unowned GettextPo.Message m;
                while ((m = mi.next_message ()) != null)
                {
                    this.messages.add (new PoMessage(this, m));
                }
            }
        }

        public override Language? get_language ()
        {
            return Language.get_language_by_code("es"); //TODO
        }
    }

    public class PoFileOpener : FileOpener
    {
        private static string[] ext = {"po"};

        public override string[] extensions { get {
            return ext;
        }}


        public override ValaCAT.FileProject.File? open_file (string path, Project? p)
        {
            return new PoFile.full (path, p);
        }
    }

}