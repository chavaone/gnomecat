

using ValaCAT.FileProject;
using ValaCAT.Languages;
using ValaCAT.UI;
using Gee;

namespace ValaCAT.Demo
{

    string string_random (int length = 8, string charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"){
        string random = "";

        for (int i=0;i<length;i++){
            int random_index = Random.int_range (0, charset.length);
            string ch = charset.get_char (charset.index_of_nth_char (random_index)).to_string ();
            random += ch;
        }

        return random;
    }


    public class DemoFile : ValaCAT.FileProject.File
    {

        public DemoFile ()
        {
            base ();
            int num = Random.int_range (100, 300);
            for (int i = 0; i < num; i++)
            {
                this.add_message (new DemoMessage (this));
            }
        }

        public override void save_file (string? file_path=null){}

        /**
         * Method that parses a file in order to populate
         *  this instance of File.
         */
        public override void parse_file (string path){}

        public override Language? get_language ()
        {
            return Language.get_language_by_code ("pl");
        }

    }

    public class DemoMessage : ValaCAT.FileProject.Message
    {
        private string original_singular;
        private string original_plural;
        private bool _has_plural;
        private TreeMap<int, string> translations;
        private string context;

        public DemoMessage (ValaCAT.FileProject.File owner)
        {
            base (owner);

            original_singular = string_random (Random.int_range (16,40));
            original_plural = Random.int_range (0,5) == 0 ? string_random (Random.int_range (16, 40)) : null;
            this._has_plural = original_plural != null;
            this.translations = new TreeMap<int, string> ();

            if (Random.int_range (0, 4) != 0)
                this.translations.set (0, string_random (Random.int_range (16, 40)));

            if (_has_plural)
                for (int i = 1; i < this.get_language ().get_number_of_plurals (); i++)
                    if (Random.int_range (0, 4) != 0)
                        this.translations.set (i,string_random (Random.int_range (16,40)));

            int random = Random.int_range (0,3);
            this.state = random == 0 ? MessageState.TRANSLATED
                       : random == 1 ? MessageState.UNTRANSLATED
                       : MessageState.FUZZY;
            this.context = string_random (99);

            if (this.state != MessageState.UNTRANSLATED)
            {
                random = Random.int_range (0,9);
                for (int i = 0; i < random; i++)
                {
                    int n = Random.int_range (0,3);
                    this.add_tip (
                        new MessageTip (
                            "Just a tip",
                            string_random (Random.int_range (16,25)),
                            n == 0 ? TipLevel.INFO :
                            n == 1 ? TipLevel.WARNING :
                            TipLevel.ERROR,
                            null,
                            null));
                }
            }
        }

        /**
         * Method that indicates if this string has or has not
         *  a plural form.
         */
        public override bool has_plural ()
        {
            return this._has_plural;
        }

        /**
         * Returns the originals singular text of this message.
         */
        public override string get_original_singular ()
        {
            return this.original_singular;
        }

        /**
         * Returns the original plural text of this message or
         *  \\null\\ if there is no plural.
         */
        public override string get_original_plural ()
        {
            return this.original_plural;
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
            return this.translations.get (index);
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
            this.translations.set (index,translation);
        }

        public override string get_context ()
        {
            return this.context;
        }

    }
}
