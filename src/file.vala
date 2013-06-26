

using Gee;
using ValaCAT.Settings;

namespace ValaCAT.FileProject
{

	/*
	 * Enum for the levels of Message Tips.
	 */
	public enum TipLevel
	{
		INFO,
		WARNING,
		ERROR
	}


	/*
	 * This class represents information that can be added to Messages in order
	 *	to indicate that they have some failure or something that can be
	 *	improved.
	 */
	public class MessageTip : Object
	{

		/*--------------------------- PROPERTIES ----------------------------*/

		/*
		 * Name of the MessageTip.
		 */
		public string name {get; private set;}

		/*
		 * Description of the MessageTip.
		 */
		public string description {get; private set;}

		/*
		 * Description of the MessageTip. It can be **INFO**, **WARNING** or **ERROR**.
		 */
		public TipLevel level {get; private set;}

		/*---------------------------- CONSTRUCTORS --------------------------*/

		public MessageTip (string name,
				string? description,
				TipLevel? level)
		{
			this.name = name;
			this.description = description;
			this.level = level == null ? TipLevel.INFO : level;
		}
	}


	/*
	 * State of a message.
	 */
	public enum MessageState
	{
		TRANSLATED,
		UNTRANSLATED,
		FUZZY,
		OBSOLETE
	}


	/*
	 * Represents a instace of each message to be translated.
	 */
	public class Message : Object
	{

		/*--------------------------- PROPERTIES ----------------------------*/

		/*
		 * File which is the owner of this message.
		 */
		public File owner_file {get; private set;}

		/*
		 * Original singular string which has to be translated.
		 */
		public string original_string_singular {get {return original_strings.get_at(0);}}

		/*
		 * Original plural string which has to be translated.
		 */
		public string original_string_plural {get {return original_strings.get_at(1);} default = null;}

		/*
		 * Context of this message.
		 */
		public string context {get; private set; default = null;}

		/*
		 * Translator comments.
		 */
		public string translator_comments {get; set; default = null;}

		/*
		 * Extracted comments from code.
		 */
		public string extracted_comments {get; private set; default = null;}

		/*
		 * State of the message.
		 */
		public MessageState state {get; private set; default = MessageState.OBSOLETE;}

		/*
		 * List of tips that this message has.
		 */
		public ArrayList<MessageTip> tips {get; private set;}


		/*------------------------- PRIVATE VARIABLES ------------------------*/

		private ArrayList<string> original_strings;
		private ArrayList<string> translated_strings;


		/*---------------------------- CONSTRUCTORS --------------------------*/

		/*
		 * Contructor for Message objects.
		 */
		public Message ()
		{
			this.original_strings = new ArrayList<string> ();
			this.tips = new ArrayList<MessageTip> ();
			this.translated_strings = new ArrayList<string> ();
		}


		/**
		 * Signal for modified translations.
		 *
		 * @param modified_message The modified message.
		 * @param index Index of the modified translation.
		 * @param old_string Previous translation if any.
		 * @param new_string New translation if any.
		 */
		public signal void modified_translation (Message modified_message
											int index,
											string? old_string,
											string? new_string);


		/*----------------------------- METHODS ------------------------------*/

		/*
		 * Gets the translated string that has the number
		 *	provided by parameter.
		 *
		 * @param index Number of the requested translation.
		 * @return The translated string.
		 */
		public string get_translation (int index)
		{
			//TODO: check index < number of plurals.
			return translated_strings.get_at(index);
		}

		/*
		 * Modifies the translated string that has the number
		 *	provided by paramenter.
		 *
		 * @param index
		 * @param translation
		 * @return The previous string or \\null\\ if there
		 * 	isn't previous string
		 */
		public string set_translation (	int index,
										string translation)
		{
			//TODO: check index < number of translations
			string old_string = translated_strings.get(index);
			translated_strings.set(index,translation);
			this.modified_translation(this, index, old_string, translation);
			return old_string;
		}

		/*
		 * Method which adds a MessageTip to this message.
		 *
		 * @param tip Message to add.
		 */
		public void add_tip (MessageTip tip)
		{
			return tips.add(tip);
		}

		/*
		 * Method that removes the MessageTip provided
		 *	as parameter.
		 *
		 * @param tip Tip to be removed.
		 */
		public void remove_tip (MessageTip tip)
		{
			return tips.remove(tip);
		}
	}

	/**
	 * Header of a file.
	 */
	public class Header : Object
	{
		//TODO
	}


	/**
	 * Represents a File that stores messages to be translated.
	 */
	public class File : Object
	{

		/*---------------------------- PROPERTIES --------------------------*/

		/*
		 * Default file extension.
		 */
		public string file_extension {get; private set; default = null;}

		/*
		 * Path to the original file.
		 */
		public string file_path {get; private set; default = null;}

		/*
		 * Number of fuzzy messages of this file.
		 */
		public int number_of_fuzzy
			{
				get
				{
					if (! valid_cache )
						set_number_of_fuzzy ();
					return cache_number_of_fuzzy;
				}
				default = 0;
			}

		/*
		 * Number of translated messages.
		 */
		public int number_of_translated
			{
				get
				{
					if (! valid_cache )
						set_number_of_translated ();
					return cache_number_of_translated;
				}
				default = 0;
			}

		/*
		 * Total number of messages.
		 */
		public int number_of_messages
			{
				get
				{	//FIXME: obsolete messages are in this list too.
					return messages.size();
				}
			}

		/*
		 * Total number of messages.
		 */
		public int number_of_untranslated
			{
				get
				{
					return number_of_messages - number_of_translated - number_of_fuzzy;
				}
			}

		/*
		 * Project which belongs this file or \\null\\ if there is no project.
		 */
		public Project project {get; private set; default = null;}

		/*
		 * List of messages.
		 */
		public ArrayList<Message> messages {get; private set;}

		/*
		 * Header of this file.
		 */
		public Header header {get; private set;}

		/*------------------------- PRIVATE VARIABLES --------------------------*/

		private bool file_changed;
		private int autosave_timeout;
		private int cache_number_of_fuzzy;
		private int cache_number_of_translated;
		private bool valid_cache;


		/*---------------------------- CONSTRUCTORS --------------------------*/

		/*
		 * General contructor. Initializes the messages list.
		 */
		public File ()
		{
			this.full(null,null);
		}

		public File.with_file_path (string file_path)
		{
			this.full(file_path, null);
		}

		public File.with_project (Project proj)
		{
			this.full(null, proj);
		}

		public File.full (string? file_path, Project? proj)
		{
			this.messages = new ArrayList<string>();
			this.file_path = file_path;
			this.project = proj;
		}

		/*------------------------------ METHODS -----------------------------*/

		/**
		 * Method that adds a new message to the file.
		 *
		 * @param m Message to add.
		 */
		public void add_message (Message m)
		{
			this.messages.add(m);
			//TODO: update total, translated, untranslated and fuzzy counts.
		}

		/**
		 * Method that deletes a message from the file.
		 *
		 * @param m Message to delete.
		 */
		public void remove_message (Message m)
		{
			this.messages.remove(m);
			//TODO: update total, translated, untranslated and fuzzy counts.
		}
	}


	/*
	 * Project that contains files.
	 */
	public class Project : Configurable
	{

		/*---------------------------- PROPERTIES ----------------------------*/

		/**
		 * List of files of the project.
		 */
		public ArrayList<File> files {get; private set;}

		/**
		 * Name of the project.
		 */
		public string name
			{
				get
				{
					return this.get_own_config("name") as string;
				}
			}


		/*------------------------- PRIVATE VARIABLES ------------------------*/

		private string config_file_path;
		private ProjectSettings project_settings;


		/*--------------------------- CONSTRUCTORS ---------------------------*/

		/**
		 * Creates a new project using a configuration file.
		 *
		 * @param config_file Paht to the existent config_file.
		 */
		public Project (string config_file)
		{
			this.config_file_path = config_file;
			this.project_settings = new ProjectSettings();
			this.project_settings.parse(config_file);
			this.files = new ArrayList<File>();
			this.scan_files();
		}

		/**
		 * Creates a new project in a directory.
		 *
		 * @param folder_path Path to the folder project.
		 * @param name Name of the new project.
		 */
		public Project.from_folder (string folder_path, string name)
		{
			//TODO
		}

		/*------------------------------ METHODS -----------------------------*/

		/**
		 *
		 */
		public override Object get_own_config (string key)
		{
			return project_settings.get_value(key);
		}

		/**
		 *
		 */
		public override Object set_own_config (string key,
									Object new_value)
		{
			return project_settings.set_value (key, new_value);
		}

		/**
		 * Explores the project directory searching compatible files and
		 *	it adds them to the project.
		 */
		public void scan_files ()
		{
			//TODO
		}


		/**
		 *
		 */
		private void add_file (File f)
		{
			this.files.add(f);
		}
	}

}
