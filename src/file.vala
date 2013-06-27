

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
	public abstract class Message : Object
	{

		/*--------------------------- PROPERTIES ----------------------------*/

		/**
		 * File which is the owner of this message.
		 */
		public File owner_file {get; private set; default = null;}

		/**
		 * State of the message.
		 */
		public MessageState state {get;
					protected set
						{
							MessageState aux = this.state;
							state = value;
							this.changed_state(aux,value);
						}
					default = MessageState.OBSOLETE;}

		/*
		 * List of tips that this message has.
		 */
		public ArrayList<MessageTip> tips {get; private set; default = null;}


		/*---------------------------- CONSTRUCTORS --------------------------*/

		/*
		 * Contructor for Message objects.
		 *
		 * @param owner_file
		 */
		public Message (File owner_file)
		{
			this.owner_file = owner_file;
			this.tips = new ArrayList<MessageTip> ();
		}


		/*------------------------------ SIGNALS -----------------------------*/

		/**
		 * Signal for modified translations.
		 *
		 * @param modified_message The modified message.
		 * @param index Index of the modified translation.
		 * @param old_string Previous translation if any.
		 * @param new_string New translation if any.
		 */
		public signal void modified_translation (int index,
											string? old_string,
											string? new_string);

		/**
		 * Signal emited when the state of a message changes.
		 */
		public signal void changed_state (MessageState old_state,
										MessageState new_state);

		/**
		 * Signal emited when a new tip is added to this message.
		 *
		 * @param tip Added tip.
		 */
		public signal void added_tip (MessageTip tip);

		/**
		 * Signal emited when a new tip is deleted from this message.
		 *
		 * @param tip Deleted tip.
		 */
		public signal void removed_tip (MessageTip tip);



		/*----------------------------- METHODS ------------------------------*/

		/*
		 * Gets the translated string that has the number
		 *	provided by parameter.
		 *
		 * @param index Number of the requested translation.
		 * @return The translated string.
		 */
		public abstract string get_translation (int index);

		/*
		 * Modifies the translated string that has the number
		 *	provided by paramenter.
		 *
		 * @param index
		 * @param translation
		 * @return The previous string or \\null\\ if there
		 * 	isn't previous string
		 */
		public abstract set_translation (int index,
										string translation);

		/*
		 * Method which adds a MessageTip to this message.
		 *
		 * @param tip Message to add.
		 */
		public void add_tip (MessageTip tip)
		{
			tips.add(tip);
			this.added_tip(tip);
		}

		/*
		 * Method that removes the MessageTip provided
		 *	as parameter.
		 *
		 * @param tip Tip to be removed.
		 */
		public void remove_tip (MessageTip tip)
		{
			tips.remove(tip);
			this.removed_tip(tip);
		}
	}


	/**
	 * Represents a File that stores messages to be translated.
	 */
	public abstract class File : Object
	{

		/*---------------------------- PROPERTIES --------------------------*/

		/*
		 * Project which belongs this file or \\null\\ if there is no project.
		 */
		public Project project {get; protected set; default = null;}

		/*
		 * List of messages.
		 */
		public ArrayList<Message> messages {get; protected set; default = null;}

		/**
		 * Path to the original file.
		 */
		public string file_path {get; protected set;}

		/**
		 * Number of untranlated messages.
		 */
		public int number_of_untranslated
			{
				get
				{
					return cache_number_of_untranslated;
				}
			}

		/**
		 * Number of translated messages.
		 */
		public int number_of_translated
			{
				get
				{
					return cache_number_of_translated;
				}
			}

		/**
		 * Number of fuzzy messages.
		 */
		public int number_of_fuzzy
			{
				get
				{
					return cache_number_of_fuzzy;
				}
			}

		/**
		 * Total number of messages.
		 */
		public int number_of_messages
			{
				get
				{
					return cache_number_of_untranslated +
						cache_number_of_translated +
						cache_number_of_fuzzy;
				}
			}


		/*------------------------- PRIVATE VARIABLES --------------------------*/

		private int cache_number_of_untranslated;
		private int cache_number_of_fuzzy;
		private int cache_number_of_translated;


		/*---------------------------- CONSTRUCTORS --------------------------*/

		/**
		 * Simple constructor. Initializes an empty isntance.
		 */
		public File ()
		{
			this.full(null,null);
		}

		/**
		 * Creates a new File using the file path
		 *	provided as parameter.
		 */
		public File.with_file_path (string file_path)
			throws FileParserNotFoundError
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
			if(file_path != null)
				this.parse_file(file_path);

			this.project = proj;

		}


		/*------------------------------ SIGNAL -----------------------------*/


		/*------------------------------ METHODS -----------------------------*/

		/**
		 * Method that adds a new message to the file.
		 *
		 * @param m Message to add.
		 */
		public void add_message (Message m)
		{
			this.messages.add(m);
			this.connect_message(m);

			switch (m.state) //Updates file statistics.
			{
			case TRANSLATED:
				this.cache_number_of_translated++;

			case UNTRANSLATED:
				this.cache_number_of_untranslated++;

			case FUZZY:
				this.cache_number_of_fuzzy++;
			}
		}

		/**
		 * Method that deletes a message from the file.
		 *
		 * @param m Message to delete.
		 */
		public void remove_message (Message m)
		{
			this.messages.remove(m);
			this.disconnect_message(m);

			switch (m.state) //Updates file statistics.
			{
			case TRANSLATED:
				this.cache_number_of_translated--;

			case UNTRANSLATED:
				this.cache_number_of_untranslated--;

			case FUZZY:
				this.cache_number_of_fuzzy--;
			}
		}

		/**
		 * Method that rebuild file statistics about number
		 *	of fuzzy, translated and untranslated.
		 */
		protected void rebuild_numbers_cache ()
		{
			this.cache_number_of_translated = 0;
			this.cache_number_of_fuzzy = 0;
			this.cache_number_of_untranslated = 0;

			foreach (Message m in this.messages)
			{
				switch (m.state)
				{
				case TRANSLATED:
					this.cache_number_of_translated++;

				case UNTRANSLATED:
					this.cache_number_of_untranslated++;

				case FUZZY:
					this.cache_number_of_fuzzy++;
				}
			}
		}

		/**
		 *
		 */
		private void connect_message (Message m)
		{
			//TODO
		}

		/**
		 *
		 */
		private void disconnect_message (Message m)
		{
			//TODO
		}

		/**
		 * Method that saves the instance of this File into
		 *	a file indicated as parameter.
		 */
		public abstract void save_file (string file_path);

		/**
		 * Method that parses a file in order to populate
		 *	this instance of File.
		 */
		public abstract void parse_file (string path);
	}


	/*
	 * Project that contains files.
	 */
	public class Project : Object
	{

		/*---------------------------- PROPERTIES ----------------------------*/

		/**
		 * List of files of the project.
		 */
		public ArrayList<File> files {get; private set;}

		/**
		 * Name of the project.
		 */
		public string name {get; protected set;}


		/*------------------------- PRIVATE VARIABLES ------------------------*/

		private string config_file_path;


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


		/**
		 *
		 */
		private void remove_file (File f)
		{
		 	this.files.remove(f);
		}
	}

}
