

using Gee;

namespace ValaCAT.Settings
{


	/*
	 * Interface for Configurable objects.
	 */
	public interface Configurable
	{
		/*
		 * Method that return a configuration value for a certain
		 *	object and key word.
		 *
		 * @param key
		 * @return
		 */
		public abstract Object get_own_config (string key);

		/*
		 * Method that sets the value for a specific key.
		 *
		 * @param key Key of the new value.
		 * @param new_value New value to set.
		 * @return The previous value if any.
		 */
		 public abstract Object? set_own_config (string key,
										Object new_value);
	}



	/**
	 *
	 */
	public abstract class SettingsManager : Object
	{

		/*---------------------------- PROPERTIES ----------------------------*/

		/**
		 * Values stored in this settings manager.
		 */
		public HashMap<String,Object> values {get; private set;}


		/*------------------------------ METHODS -----------------------------*/

		/**
		 *
		 *
		 * @param key
		 */
		public Object get_value (string key)
		{
			return values.get(key);
		}

		/**
		 *
		 *
		 * @param key
		 * @param new_value
		 */
		public Object set_value (string key,
								Object new_value)
		{
			Object aux_obj = values.get(key);
			values.set(key, new_value);
			return aux_obj;
		}


		/**
		 * Method that saves the actual settings in some
		 *	format that can be retrieved later.
		 */
		public abstract void save_config();

		/**
		 * Method that parses some store format to be
		 *	able to get the previous settings.
		 */
		public abstract void parse_config();

	}
}