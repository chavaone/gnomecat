


namespace ValaCAT.String
{

	/**
	 * Abstract class that represents every string
	 *	that the messages have.
	 *
	 */
	public abstract class MessageString : Object
	{

		/**
		 * Method that returns the message string to be
		 *	displayes using Pango.
		 *
		 * @return The string with its markup.
		 */
		public abstract string get_string ();

		/**
		 * Method that returns the message string without
		 *	any kind of markup.
		 *
		 * @return The string without any markup.
		 */
		public abstract string get_raw_string ();

		/**
		 * Method that disables the first filter of this MessageString.
		 *
		 * Default implementation, it does nothing.
		 *
		 * @param cascade Boolean value that indicates if the
		 *		disable must be recursive.
		 */
		public virtual void disable (bool cascade)
		{}
	}


	/**
	 * Base implementation of MessageString that
	 *	returns a stored string.
	 */
	public class BaseString : MessageString
	{

		/*------------------------- PRIVATE VARIABLES ------------------------*/

		private string str;


		/*--------------------------- CONSTRUCTORS ---------------------------*/

		/**
		 * Contructor of the Message. It just inicialize the string
		 *	value with the string provided as parameter.
		 *
		 * @str
		 */
		public BaseString (string str)
		{
			this.str = str;
		}


		/*------------------------------ METHODS -----------------------------*/

		/**
		 * Method that returns the message string to be
		 *	displayes using Pango.
		 *
		 * This implementation of the method simple returns
		 *	the stored string.
		 *
		 * @return The string with its markup.
		 */
		public override string get_string ()
		{
			return str;
		}

		/**
		 * Method that returns the message string without
		 *	any kind of markup.
		 *
		 * @return The string without any markup.
		 */
		public override string get_raw_string ()
		{
			return str;
		}
	}


	/**
	 *
	 */
	public abstract class Filter : MessageString
	{

		/**
		 *
		 */
		public MessageString base_message_string {get; set;}

		/*------------------------- PRIVATE VARIABLES ------------------------*/

		private bool enabled;


		/*---------------------------- CONSTRUCTOR -----------------------------*/

		/**
		 * Constructor of the method that initializes
		 *	the base string.
		 *
		 * @param initial_message Instance of the base string.
		 */
		public Filter.with_base_message (MessageString? initial_message)
		{
			this.base_message_string = initial_message;
			this.enabled = true;
		}

		/**
		 * Creates a new filter without asigning a base message.
		 */
		public Filter ()
		{
			this.with_base_message(null);
		}


		/*------------------------------ METHODS -----------------------------*/

		/**
		 * Method that returns the message string to be
		 *	displays using Pango.
		 *
		 * This implementation retrieves the string for
		 *	the base_string and it applies to it a filter.
		 *
		 * @return The string with its markup.
		 */
		public override string get_string ()
		{
			string aux_str = base_message_string.get_string();
			return enabled ? this.filter(aux_str) : aux_str;
		}

		/**
		 * Method that returns the message string without
		 *	any kind of markup.
		 *
		 * @return The string without any markup.
		 */
		public override string get_raw_string ()
		{
			return this.base_message_string.get_raw_string();
		}

		/**
		 * Method that disables this filter.
		 *
		 * Implements a logical delete. If cascade is set then
		 *	the logical delete is recursive.
		 *
		 * @param cascade Boolean value that indicates if the
		 *		disable must be recursive.
		 */
		public override void disable (bool cascade)
		{
			this.enabled = false;
			if (cascade)
			{
				this.base_message_string.disable(true);
			}
		}


		/**
		 * Method that modifies the string provided as parameter.
		 *
		 * @param input_string Initial string.
		 * @return String modified.
		 */
		public abstract string filter (string input_string);
	}

}