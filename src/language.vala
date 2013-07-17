
namespace ValaCAT.Languages
{

	public class PluralForm : Object
	{
		/**
		 *
		 */
		 public int id {get; private set;}

		/**
		 *
		 */
		public int number_of_plurals {get; private set;}

		/**
		 *
		 */
		public string expresion {get; private set;}

		/**
		 *
		 */
		public ArrayList<string> plural_tags {get; private set;}



		private static ArrayList<PluralForm> instances;


		/**
		 *
		 */
		public PluralForm.full(int number_of_plurals, string expresion, ArrayList<string> plural_tags)
		{
			this.number_of_plurals = number_of_plurals;
			this.expresion = expresion;
			this.plural_tags = plural_tags;
		}


		/**
		 * Method that return the tag for a plural form.
		 *
		 * There are languages that has different plural forms for
		 * different numbers these tags try to provide a more readable
		 * form to distinguish among this form.
		 */
		public string get_plural_form_tag (int plural)
		{
			return plural_tags.get(plural);
		}

		/**
		 * Method that returns the instance corresponding the
		 * id number provided as parameter.
		 */
		public static PluralForm get_plural_from_id (int id)
		{
			if(instances == null)
				lazy_init();
			return instances.get(id);
		}

		private void lazy_init ()
		{
		}
	}


	public class Language : Object
	{

		public static HashMap<string,Language> languages {get; private set;}


		public string name {get; private set;}
		public string code {get; private set;}
		public PluralForm plural_form {get; private set;}


		public static Language get_language_by_code (string code)
		{
			if(languages == null)
				lazy_init();
			languages.get(code);
		}

		public Language (string code, string name, int? pluralform)
		{
			this.name = name;
			this.code = code;
			this.plural_form = PluralForm.get_plural_from_id(pluralform);
		}

		public int get_number_of_plurals ()
		{
			return plural_form.number_of_plurals;
		}

		public string? get_plural_form_tag (int plural)
		{
			if (this.plural_form == null)
				return null;
			return this.plural_form.get_plural_form_tag(plural);
		}

		private void lazy_init ()
		{
			languages = new HashMap<string, Language>();

			var parser = new Json.Parser ();
			parser.load_from_data (); //TODO
			var root_object = parser.get_root ().get_object ();

			foreach (var lang in root_object.get_array_member ("languages").get_elements ()) {
	            var lang_object = lang.get_object ();

	            string name = lang_object.get_string_member("name");
	            string code = lang_object.get_string_member("code");

	            if ( lang_object.has_member("pluralform") )
	            {
	            	int plural_form_id = lang_object.get_int_member("pluralform");
	            	PluralForm plural_form_instance = PluralForm.get_plural_from_id(plural_form_id);
	            	languages.set(code, new Language(name, code, plural_form_instance));
	            }
	            else
	            {
	            	languages.set(code, new Language(name, code, null));
	            }

        }
		}
	}
}